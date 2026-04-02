"""
Apollo.io Company & Contact Scraper via RapidAPI
Outputs a HubSpot-ready CSV with company and contact information.
"""

import http.client
import json
import csv
import time
import sys
import os
from urllib.parse import urlencode

# ─── Configuration ───────────────────────────────────────────────────────────
RAPIDAPI_KEY = os.environ.get("RAPIDAPI_KEY", "3902289fd3mshb3add55ecc041d3p13ca29jsn88b7baa5198a")
RAPIDAPI_HOST = "apollo-io-no-cookies-required.p.rapidapi.com"

HEADERS = {
    "x-rapidapi-key": RAPIDAPI_KEY,
    "x-rapidapi-host": RAPIDAPI_HOST,
    "Content-Type": "application/json",
}

# ─── Search filters (edit these before running) ──────────────────────────────
SEARCH_PARAMS = {
    "q_organization_name": "",           # e.g. "Google"
    "organization_locations": "",         # e.g. "France" or "United States,United Kingdom"
    "organization_num_employees_ranges": "",  # e.g. "1-10" or "51-100"
    "q_organization_keyword_tags": "",    # e.g. "cloud,saas"
    "organization_industry_tag_ids": "",  # comma-separated industry tag IDs
    "zip_code": "",                       # e.g. "75001"
    "organization_location_radius": "",   # 25, 50, 100, or 300
}

# ─── People search filters (edit these to filter contacts) ───────────────────
PEOPLE_SEARCH_PARAMS = {
    "person_titles": "",                 # e.g. "CEO,CTO,Founder"
    "person_not_titles": "",             # titles to exclude
    "person_past_titles": "",            # past job titles
    "person_locations": "",              # e.g. "France,Paris"
    "contact_email_status_v2": "",       # "verified", "likely_to_engage", etc.
    "q_person_name": "",                 # search by person name
}

# How many pages of organizations to scrape (25 orgs per page)
MAX_ORG_PAGES = 1

# How many pages of people per organization (25 people per page)
MAX_PEOPLE_PAGES = 1

OUTPUT_FILE = "hubspot_import.csv"

# Delay between API calls (seconds) to respect rate limits
API_DELAY = 1.0


# ─── API helpers ─────────────────────────────────────────────────────────────

def api_get(path):
    """Make a GET request to the Apollo RapidAPI and return parsed JSON."""
    conn = http.client.HTTPSConnection(RAPIDAPI_HOST)
    conn.request("GET", path, headers=HEADERS)
    res = conn.getresponse()
    data = res.read()
    conn.close()
    if res.status != 200:
        print(f"  [WARN] API returned status {res.status} for {path}")
        return None
    try:
        return json.loads(data.decode("utf-8"))
    except json.JSONDecodeError:
        print(f"  [WARN] Invalid JSON response for {path}")
        return None


def search_organizations(page=1):
    """Search organizations with configured filters."""
    params = {"page": str(page)}
    for key, value in SEARCH_PARAMS.items():
        if value:
            params[key] = value
    query = urlencode(params)
    return api_get(f"/search_organization?{query}")


def search_people(organization_id, page=1):
    """Search people within a specific organization, with optional filters."""
    params = {
        "organization_ids": organization_id,
        "page": str(page),
    }
    for key, value in PEOPLE_SEARCH_PARAMS.items():
        if value:
            params[key] = value
    query = urlencode(params)
    return api_get(f"/search_people?{query}")


def get_person_details(person_id):
    """Get detailed info for a specific person (includes email)."""
    return api_get(f"/person_details?person_id={person_id}")


# ─── Main scraping logic ────────────────────────────────────────────────────

def scrape():
    all_rows = []

    # Clean search params display
    active_filters = {k: v for k, v in SEARCH_PARAMS.items() if v}
    if not active_filters:
        print("[ERROR] No search filters configured. Edit SEARCH_PARAMS in the script.")
        print("  At minimum, set q_organization_name or organization_locations.")
        sys.exit(1)

    print(f"Search filters: {active_filters}")
    print(f"Scraping up to {MAX_ORG_PAGES} page(s) of organizations...\n")

    for org_page in range(1, MAX_ORG_PAGES + 1):
        print(f"--- Organization page {org_page} ---")
        org_result = search_organizations(page=org_page)
        time.sleep(API_DELAY)

        if not org_result or "data" not in org_result:
            print("  No data returned. Stopping.")
            break

        organizations = org_result["data"].get("organizations", [])
        pagination = org_result["data"].get("pagination", {})
        total_entries = pagination.get("total_entries", 0)
        total_pages = pagination.get("total_pages", 0)
        print(f"  Found {total_entries} total organizations ({total_pages} pages)")

        if not organizations:
            print("  No organizations on this page. Stopping.")
            break

        for org in organizations:
            org_name = org.get("name", "")
            org_phone = org.get("phone") or ""
            org_domain = org.get("primary_domain") or org.get("website_url") or ""
            org_linkedin = org.get("linkedin_url") or ""
            org_industry = ""  # Apollo search_organization doesn't return industry directly

            # Clean domain: remove http(s)://www. prefix
            if org_domain.startswith("http"):
                org_domain = org_domain.split("//", 1)[-1]
                if org_domain.startswith("www."):
                    org_domain = org_domain[4:]

            # Skip orgs without phone (required field)
            if not org_phone:
                print(f"  Skipping '{org_name}' (no phone)")
                continue

            org_id = org.get("id", "")
            print(f"  Processing org: {org_name} ({org_id})")

            # Get organization details for industry
            org_details_data = api_get(f"/organization_details?organization_id={org_id}")
            time.sleep(API_DELAY)
            if org_details_data and "data" in org_details_data:
                org_detail = org_details_data["data"].get("organization", {})
                org_industry = org_detail.get("industry", "") or ""
                # Update domain if we got a better one
                if not org_domain and org_detail.get("primary_domain"):
                    org_domain = org_detail["primary_domain"]

            # Skip if missing required fields
            if not org_domain:
                print(f"    Skipping '{org_name}' (no domain)")
                continue

            # Search people in this organization
            found_contact = False
            for people_page in range(1, MAX_PEOPLE_PAGES + 1):
                people_result = search_people(org_id, page=people_page)
                time.sleep(API_DELAY)

                if not people_result or "data" not in people_result:
                    break

                people = people_result["data"].get("people", [])
                if not people:
                    break

                for person in people:
                    person_id = person.get("id", "")
                    first_name = person.get("first_name", "")
                    last_name = person.get("last_name", "")
                    full_name = f"{first_name} {last_name}".strip()
                    title = person.get("title") or ""
                    person_email = person.get("email") or ""
                    person_phone = ""

                    # If no email from search, get person details
                    if not person_email and person_id:
                        print(f"    Fetching details for {full_name}...")
                        detail_data = get_person_details(person_id)
                        time.sleep(API_DELAY)
                        if detail_data and "data" in detail_data:
                            person_detail = detail_data["data"].get("person", {})
                            person_email = person_detail.get("email") or ""
                            person_phone = person_detail.get("sanitized_phone") or ""
                            if not title:
                                title = person_detail.get("title") or ""

                    # Skip contacts without required fields
                    if not person_email or not full_name or not title:
                        continue

                    row = {
                        "Nom de l'entreprise": org_name,
                        "Secteur": org_industry,
                        "Numero de telephone Entreprise": org_phone,
                        "Details": org_linkedin,
                        "Nom de domaine": org_domain,
                        "Nom / Prenom du contact cible": full_name,
                        "Email": person_email,
                        "Numero de telephone": person_phone,
                        "Intitule du poste": title,
                    }
                    all_rows.append(row)
                    found_contact = True
                    print(f"    + {full_name} - {title} ({person_email})")

            if not found_contact:
                print(f"    No valid contacts found for '{org_name}'")

        # Stop if we've reached the last page
        if org_page >= total_pages:
            print("\n  Reached last page of results.")
            break

    # ─── Write CSV ───────────────────────────────────────────────────────
    if not all_rows:
        print("\nNo data collected. CSV not created.")
        return

    fieldnames = [
        "Nom de l'entreprise",
        "Secteur",
        "Numero de telephone Entreprise",
        "Details",
        "Nom de domaine",
        "Nom / Prenom du contact cible",
        "Email",
        "Numero de telephone",
        "Intitule du poste",
    ]

    output_path = os.path.join(os.path.dirname(__file__), OUTPUT_FILE)
    with open(output_path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter=";")
        writer.writeheader()
        writer.writerows(all_rows)

    print(f"\nDone! {len(all_rows)} contacts exported to {output_path}")


if __name__ == "__main__":
    scrape()
