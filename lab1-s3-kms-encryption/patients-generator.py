# patients-generator.py
# Generates synthetic PHI-like data for Lab 1 (NO real PHI).
# Usage: python3 patients-generator.py

import csv, random
from datetime import datetime
try:
    from faker import Faker
except ImportError:
    raise SystemExit("Install Faker first: pip install faker")

fake = Faker()
Faker.seed(1234)
rows = []
n = 100

diagnoses = ["Asthma","Diabetes","Hypertension","Flu","COVID-19","Allergy","Broken Arm","Chest Pain"]
insurers = ["Aetna","BlueCross","Cigna","UnitedHealth","Medicare","Medicaid"]
notes = ["Follow-up in 2 weeks","Prescribed medication","Patient stable","Needs lab tests","Refer to specialist","Emergency admission required"]

for i in range(1, n+1):
    ssn = fake.ssn()
    rows.append({
        "patient_id": i,
        "name": fake.name(),
        "dob": fake.date_of_birth(minimum_age=18, maximum_age=90).strftime("%Y-%m-%d"),
        "address": fake.address().replace("\n", ", "),
        "diagnosis": random.choice(diagnoses),
        "visit_timestamp": fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S"),
        "insurer": random.choice(insurers),
        "claim_id": fake.bothify("CLAIM-####??"),
        "ssn": ssn,
        "last4": ssn[-4:],
        "notes": random.choice(notes),
    })

outfile = "patients.csv"
with open(outfile, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    writer.writeheader()
    writer.writerows(rows)

print(f"Wrote {len(rows)} rows to {outfile}")
