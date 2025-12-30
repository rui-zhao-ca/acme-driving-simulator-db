# ACME Simulators Database

A relational database system for managing driving simulator projects, documentation, and client configurations.

## Overview

ACME Simulators provides driving simulators for automobile manufacturers and training organizations. This database manages simulator projects, product/platform configurations, versioned documentation, and approval workflows.

## Repository Structure

```
acme-simulators-db/
├── README.md
├── docs/
│   └── Database_Project_Doc.pdf    # ERD, data dictionary, and relational schema
└── sql/
    └── schema_and_data.sql         # Table definitions, sample data, and queries
```

## Database Schema

The database consists of 22 tables organized into four main areas:

**Users & Roles** — User management and role-based access control

**Products & Platforms** — Simulator products, platforms, and their configurable options

**Projects & Configurations** — Client projects with selected product/platform configurations

**Documents & Versioning** — Versioned documentation with sections, approval workflows, and change tracking

### Key Entities

| Entity | Description |
|--------|-------------|
| `Project` | Client-ordered simulator projects |
| `Product` / `Platform` | Available simulator products and platforms |
| `ProductConfig` / `PlatformConfig` | Selected options for each project |
| `DocumentVersion` | Versioned documents linked to products/platforms |
| `ApprovalTask` | Document review and approval workflow |
| `ChangeLog` | Audit trail of document modifications |

## Getting Started

### Prerequisites

- MySQL 8.0+ or compatible database server

### Installation

```bash
mysql -u <username> -p <database_name> < sql/schema_and_data.sql
```

This script creates all tables, inserts sample data (10+ records per entity), and includes example analytical queries.

## Sample Queries

The SQL file includes 22 commented queries demonstrating common operations:

- Identify projects using outdated document versions
- Track document revision frequency
- Analyze client project history and loyalty
- Monitor approval rates by reviewer
- Calculate project delivery timelines

## Authors

Alexandre Courtis, Monica Jang, Nicholas Stanfield, Ibukun Adeleye, Simmi Agnihotram, Rui Zhao

*McGill University — INSY 661: Database and Distributed Systems for Analytics*
