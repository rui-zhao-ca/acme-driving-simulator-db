# ACME Simulators Database

Live demo: https://www.db-fiddle.com/f/9uxujWFUq8Gv6zBD6aas3Q/0

---
## Project Overview

ACME Simulators provides driving simulators for automakers and training organizations to test driving experiences across vehicle models and configurations. This database supports end-to-end simulator project management.

### Business Processes Supported

- **Client & project management**: track clients, projects, and project history
- **Configuration management**: capture product/platform selections and option combinations per project
- **Document lifecycle**: author documents with version control and structured content
- **Approvals & auditability**: manage approvals/comments and maintain change logs
- **Test result tracking**: record internal and client test results at the row level
- **Users & notifications**: manage roles/users and workflow/event notifications

---
## Repository Structure

```
acme-driving-simulator-db/
├── README.md
├── database_design.pdf      # Project scope, ERD, data dictionary, relational schema
└── sql/
    ├── schema_seed.sql      # Table definitions and sample data
    └── queries.sql          # 22 example analytical queries
```

---
## ERD 
![erd](https://github.com/user-attachments/assets/c70bb938-246a-429d-a7eb-ad153b21c53e)

---
## Schema Design

The database consists of **24 tables** organized into four domains:

| Domain | Tables | Purpose |
|--------|--------|---------|
| **Projects & Configs** | `Client`, `Project`, `ProductConfig`, `PlatformConfig` | Client projects with selected configurations |
| **Products & Platforms** | `Product`, `Platform`, `ProductOptions`, `PlatformOptions`, `ProductOptionValues`, `PlatformOptionValues`, `ProductOptionSelection`, `PlatformOptionSelection` | Simulator offerings and configurable options |
| **Documents & Versioning** | `Document`, `DocumentVersion`, `ProductDocument`, `PlatformDocument`, `Section`, `SectionRows`, `ChangeLog`, `ApprovalTask`, `ApprovalComments` | Versioned documentation with approval workflows |
| **Users & Roles** | `Role`, `User`, `Notification` | User management and role-based access |

### Entity Relationships

- A **Client** can order multiple **Projects**
- Each **Project** can have many **ProductConfigs** or **PlatformConfigs**
- **Products** and **Platforms** have configurable options with defined values
- **Documents** have multiple **Versions**, each containing **Sections** and **SectionRows**
- **ApprovalTasks** track the review status of each document version

---
## Example Queries

The repository includes **22 example queries** demonstrating common analytical operations. Below are the first five:

| Query # | Purpose | Business Value |
|---------|---------|----------------|
| 1 | Identify projects using outdated document versions | Proactively recommend upgrades to clients |
| 2 | Find most frequently selected option values (Product + Platform) | Inform default configuration recommendations for new projects |
| 3 | Detect product–platform configuration conflicts (e.g., AC=True with Tech Level=Low) | Prevent invalid configurations before delivery |
| 4 | List all features used per customer (product + platform option values) | Support customer success with personalized insights |
| 5 | Calculate days from project order to first approved document delivery | Identify potentially dissatisfied customers for proactive outreach |

---
## Team

Rui Zhao, Monica Jang, Ibukun Adeleye, Simmi Agnihotram, Alexandre Courtis, Nicholas Stanfield
