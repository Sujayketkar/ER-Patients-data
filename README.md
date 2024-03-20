# ER-Patients-data
I have a table containing patient data with the following columns:

•	patient_id: Unique identifier for each patient.
•	admission_date (timestamp): Date of the the patient entered the ER.
•	Adminssion_time (timestamp) : Time of the the patient entered the ER.
•	discharge_date (timestamp): Date of the patient left the ER.
•	discharge_time (timestamp): time of the patient left the ER.
•	Patient_waittime – time frame a patient wait in ER.

Considering this is an ER setting, wait times are typically measured in minutes.

While both admission and discharge timestamps are stored in a 24-hour format (e.g., 2020-03-20 08:47:00), we’re interested in analyzing patient volume within the ER.
Specifically, we want to determine the number of patients present in the ER at any given 30-minute interval throughout a 24-hour period. This could be for a specific day or a broader timeframe any much more
