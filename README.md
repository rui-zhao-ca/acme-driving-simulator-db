# ACME Simulators Database

A relational database system for managing driving simulator projects, documentation workflows, and client configurations.

## Project Overview

ACME Simulators provides driving simulators for automobile manufacturers and training organizations to test driving experiences across different vehicle models and configurations. This database system serves as the backbone for managing the entire lifecycle of simulator projects.

### Key Business Processes Supported

**Project Configuration Management** — Clients select car models (products), simulator platforms, and their respective configuration options to generate customized simulator projects. The system tracks all product/platform option combinations and validates configuration compatibility.

**Document Lifecycle & Versioning** — The system manages technical documentation that validates simulator builds and evaluates driver performance. Documents progress through authoring, reviewing, and approval workflows, with full version history and change tracking.

**Approval Workflows** — Users assume different roles (writers, reviewers, approvers) with their actions systematically recorded. The system tracks approval status, reviewer comments, and maintains audit trails for compliance.

**Test Result Tracking** — Both company-side and client-side test results are recorded at the section row level, enabling quality assurance and identifying configurations that may require attention.

**Client Relationship Management** — Track client orders, project history, and feature preferences to support business intelligence and customer success initiatives.

## Repository Structure

```
acme-driving-simulator-db/
├── README.md
├── docs/
│   └── database_design.pdf      # ERD, data dictionary, relational schema
└── sql/
    ├── schema_seed.sql          # Table definitions and sample data
    └── queries.sql              # 22 example analytical queries
```

## Database Schema

The database consists of **22 tables** organized into four domains:

| Domain | Tables | Purpose |
|--------|--------|---------|
| **Users & Roles** | `Role`, `User`, `Notification` | User management and role-based access |
| **Products & Platforms** | `Product`, `Platform`, `ProductOptions`, `PlatformOptions`, `ProductOptionValues`, `PlatformOptionValues`, `ProductOptionSelection`, `PlatformOptionSelection` | Simulator offerings and configurable options |
| **Projects & Configs** | `Client`, `Project`, `ProductConfig`, `PlatformConfig` | Client projects with selected configurations |
| **Documents & Versioning** | `Document`, `DocumentVersion`, `ProductDocument`, `PlatformDocument`, `Section`, `SectionRows`, `ChangeLog`, `ApprovalTask`, `ApprovalComments` | Versioned documentation with approval workflows |

### Entity Relationships

- A **Client** can order multiple **Projects**
- Each **Project** has one **ProductConfig** and one **PlatformConfig**
- **Products** and **Platforms** have configurable options with defined values
- **Documents** have multiple **Versions**, each containing **Sections** and **SectionRows**
- **ApprovalTasks** track the review status of each document version

## Example Queries

The repository includes **22 example queries** demonstrating common analytical operations. Below are the first five:

| Query # | Purpose | Business Value |
|---------|---------|----------------|
| 1 | Identify projects using outdated document versions | Proactively recommend upgrades to clients; ensure all projects use the latest validated documentation |
| 2 | Find most frequently selected option values (Product + Platform) | Inform default configuration recommendations for new projects; understand customer preferences |
| 3 | Detect product–platform configuration conflicts (e.g., AC=True with Tech Level=Low) | Prevent invalid configurations before delivery; reduce support tickets and project delays |
| 4 | List all features used per customer (product + platform option values) | Support customer success with personalized insights; identify upsell opportunities |
| 5 | Calculate days from project order to first approved document delivery | Monitor fulfillment SLAs; identify potentially dissatisfied customers for proactive outreach |

Additional queries cover: document value analysis (#6), premium feature sales by role (#7), failed test investigations (#8), product popularity (#9, #16), user contribution audits (#10), engine type comparisons (#11), document freshness tracking (#13), approval rate analysis (#15), client loyalty rankings (#21), and incomplete test identification (#22).

## Getting Started

### Prerequisites

- MySQL 8.0+ (required for CTEs and window functions)

### Installation

```bash
# Create database and load schema with sample data
mysql -u <username> -p <database_name> < sql/schema_seed.sql

# Run example queries
mysql -u <username> -p <database_name> < sql/queries.sql
```

The schema includes sample data with 10+ records per entity for immediate testing.

## Authors

Rui Zhao, Alexandre Courtis, Monica Jang, Nicholas Stanfield, Ibukun Adeleye, Simmi Agnihotram

*McGill University — August 2025*
