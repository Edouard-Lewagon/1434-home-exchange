# Apollo.io Company & Contact Scraper

Scrape companies and contacts from Apollo.io via RapidAPI, then export a HubSpot-ready CSV.

## Setup

No dependencies required — uses Python standard library only.

Optionally set your API key as an environment variable:
```bash
export RAPIDAPI_KEY="your_key_here"
```

## Usage

1. Edit `apollo_scraper.py` and configure `SEARCH_PARAMS`:

```python
SEARCH_PARAMS = {
    "q_organization_name": "Google",
    "organization_locations": "France",
    "organization_num_employees_ranges": "51-100",
    # ...
}
```

2. Adjust `MAX_ORG_PAGES` and `MAX_PEOPLE_PAGES` for volume.

3. Run:
```bash
python scraper/apollo_scraper.py
```

4. Import `scraper/hubspot_import.csv` into HubSpot.

## CSV Columns

| Column | Required | Description |
|--------|----------|-------------|
| Nom de l'entreprise | * | Company name |
| Secteur | * | Industry |
| Numero de telephone Entreprise | * | Company phone |
| Details | | LinkedIn URL |
| Nom de domaine | * | Primary domain |
| Nom / Prenom du contact cible | * | Contact full name |
| Email | * | Contact email |
| Numero de telephone | | Contact phone |
| Intitule du poste | * | Job title |

## Rate Limits

The script waits 1 second between API calls by default. Adjust `API_DELAY` if needed.
