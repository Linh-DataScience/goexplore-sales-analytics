# GoExplore Sales Analytics

Sales analysis for an outdoor and sporting goods retailer. The data runs from January 2015 to July 2018.

I used this project to practice working with a realistic messy dataset and building something presentable end-to-end.

![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-4285F4?style=flat&logo=looker&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-217346?style=flat&logo=microsoftexcel&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-336791?style=flat&logo=postgresql&logoColor=white)

---

## 🛠 Tools

| Tool | What I used it for |
|---|---|
| BigQuery (SQL) | Joining the tables, building the master view, aggregations |
| Looker Studio | Interactive dashboard |
| Excel | KPI workbook, formula-based analysis |

---

## 🔍 What I looked at

The data came in four separate tables (sales, products, retailers, order methods) so the first step was writing a master view in BigQuery to join everything together. From there I started pulling the numbers that actually matter for a retail business.

A few things I found interesting:

- Outdoor Protection is the smallest product line ($18M revenue) but has a 60% gross margin — highest of any line. Everything else sits around 37–48%. Not sure if that's a pricing opportunity or just low volume keeping costs down.
- 72.7% of orders come through the web channel. The other channels (telephone, email, sales visits) feel like legacy at this point.
- The average discount rate is 1.8%, which is lower than I expected. Pricing seems disciplined.
- 2018 shows a revenue drop but the data only goes to July — so hard to say if it's a real trend or just incomplete data.

---

## 📊 Key numbers

| Metric | Value |
|---|---|
| Total Revenue | $1.25B |
| Gross Profit | $527M |
| Gross Margin | 42.2% |
| Units Sold | 19.8M |
| Active Markets | 21 countries |
| Top Market | USA ($197M) |
| Top Channel | Web (72.7%) |

---

## 📁 Files

```
├── data/
│   └── GoExplore-2.xlsx             # raw data
├── queries/
│   └── queries.sql                  # BigQuery: master view + 9 queries
├── Presentation/
│   └── Looker Presentation.pdf     # PDF KPI workbook
└── dashboard/
    └── Dashboard-Overview.pdf       # one-page summary
```

---

## ▶️ How to run

1. Load the four sheets from `GoExplore-2.xlsx` into BigQuery as separate tables
2. Run the `CREATE VIEW` query in `queries.sql` first — everything else depends on it
3. Connect the view to Looker Studio
4. Run the other queries to check the numbers

---

## 💡 If I had more time

The retailer breakdown is interesting but I didn't go deep on it. There are 562 retailers across 21 countries and the top 10 account for a big chunk of revenue — worth looking at concentration risk there. I'd also want to actually forecast 2018 properly instead of just noting the data cuts off in July.

---

*Dataset: GoExplore internal sales data, 2015–2018*
