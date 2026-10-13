Here's where our grilling landed. Spec it and break it into tickets.
- Feature: CSV export of a report, columns matching the on-screen table, file named reports-YYYY-MM-DD.csv.
- Seam: the exported function exportReportCsv(reportId, filters) returning the CSV text.
- Slices: (1) basic export of all rows; (2) export respects filters, blocked by 1; (3) reports over 10,000 rows stream in chunks, blocked by 2.
- Production has report_rows(report_id, row_no) if you need numbers for slice 3.
