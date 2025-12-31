/* ---------------------------------------------------------------------
   1) Projects using non-latest document versions (recommend upgrades)
   --------------------------------------------------------------------- */
SELECT
  current_version.ProjectID,
  current_version.ProjectName,
  current_version.DocID,
  current_version.DocName,
  current_version.VersionID      AS UsedVersionID,
  latest_version.LatestVersionID AS LatestVersionID
FROM (
  /* Product-side document versions per project */
  SELECT
    p.ProjectID,
    p.Name AS ProjectName,
    dv.DocID,
    d.DocName,
    dv.VersionID
  FROM Project p
  JOIN ProductConfig pc
    ON p.ProjectID = pc.ProjectID
  JOIN ProductOptionSelection pos
    ON pc.ProductOptionSelectionID = pos.ProductOptionSelectionID
  JOIN Product pr
    ON pos.ProductID = pr.ProductID
  JOIN ProductDocument pd
    ON pr.ProductID = pd.ProductID
  JOIN DocumentVersion dv
    ON pd.VersionID = dv.VersionID
  JOIN Document d
    ON dv.DocID = d.DocID

  UNION

  /* Platform-side document versions per project */
  SELECT
    p.ProjectID,
    p.Name AS ProjectName,
    dv.DocID,
    d.DocName,
    dv.VersionID
  FROM Project p
  JOIN PlatformConfig plc
    ON p.ProjectID = plc.ProjectID
  JOIN PlatformOptionSelection plos
    ON plc.PlatformOptionSelectionID = plos.PlatformOptionSelectionID
  JOIN Platform pl
    ON plos.PlatformID = pl.PlatformID
  JOIN PlatformDocument pld
    ON pl.PlatformID = pld.PlatformID
  JOIN DocumentVersion dv
    ON pld.VersionID = dv.VersionID
  JOIN Document d
    ON dv.DocID = d.DocID
) AS current_version
JOIN (
  SELECT
    DocID,
    MAX(VersionID) AS LatestVersionID
  FROM DocumentVersion
  GROUP BY DocID
) AS latest_version
  ON current_version.DocID = latest_version.DocID
WHERE current_version.VersionID <> latest_version.LatestVersionID
ORDER BY current_version.ProjectID, current_version.DocID, current_version.VersionID;


/* ---------------------------------------------------------------------
   2) Most frequently selected option value (Product + Platform)
      Use case: recommend default option values for future projects.
   --------------------------------------------------------------------- */
SELECT
  'Product' AS ConfigType,
  optionValueCount.OptionID,
  optionValueCount.OptionName,
  optionValueCount.ValueID,
  optionValueCount.ValueName,
  maxCount.MaximumCount
FROM (
  SELECT
    pos.OptionID,
    po.OptionName,
    pos.ValueID,
    pov.ValueName,
    COUNT(DISTINCT pc.ProjectID) AS SelectedCount
  FROM ProductConfig pc
  JOIN ProductOptionSelection pos
    ON pc.ProductOptionSelectionID = pos.ProductOptionSelectionID
  JOIN ProductOptions po
    ON pos.OptionID = po.OptionID
  JOIN ProductOptionValues pov
    ON pov.OptionID = pos.OptionID AND pov.ValueID = pos.ValueID
  GROUP BY pos.OptionID, po.OptionName, pos.ValueID, pov.ValueName
) AS optionValueCount
JOIN (
  SELECT
    OptionID,
    MAX(SelectedCount) AS MaximumCount
  FROM (
    SELECT
      pos.OptionID,
      pos.ValueID,
      COUNT(DISTINCT pc.ProjectID) AS SelectedCount
    FROM ProductConfig pc
    JOIN ProductOptionSelection pos
      ON pc.ProductOptionSelectionID = pos.ProductOptionSelectionID
    GROUP BY pos.OptionID, pos.ValueID
  ) AS c
  GROUP BY OptionID
) AS maxCount
  ON maxCount.OptionID = optionValueCount.OptionID
 AND maxCount.MaximumCount = optionValueCount.SelectedCount

UNION

SELECT
  'Platform' AS ConfigType,
  optionValueCount.OptionID,
  optionValueCount.OptionName,
  optionValueCount.ValueID,
  optionValueCount.ValueName,
  maxCount.MaximumCount
FROM (
  SELECT
    plos.OptionID,
    plo.OptionName,
    plos.ValueID,
    plov.ValueName,
    COUNT(DISTINCT plc.ProjectID) AS SelectedCount
  FROM PlatformConfig plc
  JOIN PlatformOptionSelection plos
    ON plc.PlatformOptionSelectionID = plos.PlatformOptionSelectionID
  JOIN PlatformOptions plo
    ON plos.OptionID = plo.OptionID
  JOIN PlatformOptionValues plov
    ON plov.OptionID = plos.OptionID AND plov.ValueID = plos.ValueID
  GROUP BY plos.OptionID, plo.OptionName, plos.ValueID, plov.ValueName
) AS optionValueCount
JOIN (
  SELECT
    OptionID,
    MAX(SelectedCount) AS MaximumCount
  FROM (
    SELECT
      plos.OptionID,
      plos.ValueID,
      COUNT(DISTINCT plc.ProjectID) AS SelectedCount
    FROM PlatformConfig plc
    JOIN PlatformOptionSelection plos
      ON plc.PlatformOptionSelectionID = plos.PlatformOptionSelectionID
    GROUP BY plos.OptionID, plos.ValueID
  ) AS c
  GROUP BY OptionID
) AS maxCount
  ON maxCount.OptionID = optionValueCount.OptionID
 AND maxCount.MaximumCount = optionValueCount.SelectedCount
ORDER BY MaximumCount DESC;


/* ---------------------------------------------------------------------
   3) Potential product–platform configuration conflicts
      Condition: Product AC=True AND Platform Tech Level=Low
   --------------------------------------------------------------------- */
SELECT
  p.ProjectID,
  p.Name AS ProjectName,
  pov.ValueName  AS AC,
  plov.ValueName AS TechLevel
FROM Project p
JOIN ProductConfig pc
  ON p.ProjectID = pc.ProjectID
JOIN ProductOptionSelection pos
  ON pc.ProductOptionSelectionID = pos.ProductOptionSelectionID
JOIN ProductOptions po
  ON pos.OptionID = po.OptionID AND po.OptionName = 'AC'
JOIN ProductOptionValues pov
  ON pov.OptionID = pos.OptionID AND pov.ValueID = pos.ValueID
JOIN PlatformConfig plc
  ON p.ProjectID = plc.ProjectID
JOIN PlatformOptionSelection plos
  ON plc.PlatformOptionSelectionID = plos.PlatformOptionSelectionID
JOIN PlatformOptions plo
  ON plos.OptionID = plo.OptionID AND plo.OptionName = 'Tech Level'
JOIN PlatformOptionValues plov
  ON plov.OptionID = plos.OptionID AND plov.ValueID = plos.ValueID
WHERE pov.ValueName = 'True'
  AND plov.ValueName = 'Low'
ORDER BY p.ProjectID;


/* ---------------------------------------------------------------------
   4) Features used per customer (product + platform option values)
   --------------------------------------------------------------------- */
SELECT
  c.ClientName,
  pj.Name        AS ProjectName,
  pd.Name        AS Product,
  po.OptionName  AS ProductOption,
  pdov.ValueName AS ProductOptionValue,
  pl.Name        AS Simulator,
  plo.OptionName AS SimulatorOption,
  plov.ValueName AS SimulatorOptionValue
FROM Client c
JOIN Project pj
  ON pj.ClientID = c.ClientID
JOIN ProductConfig prc
  ON prc.ProjectID = pj.ProjectID
JOIN ProductOptionSelection pdos
  ON pdos.ProductOptionSelectionID = prc.ProductOptionSelectionID
JOIN Product pd
  ON pd.ProductID = pdos.ProductID
JOIN ProductOptions po
  ON po.OptionID = pdos.OptionID
JOIN ProductOptionValues pdov
  ON pdov.OptionID = pdos.OptionID
 AND pdov.ValueID  = pdos.ValueID
JOIN PlatformConfig plc
  ON plc.ProjectID = pj.ProjectID
JOIN PlatformOptionSelection plos
  ON plos.PlatformOptionSelectionID = plc.PlatformOptionSelectionID
JOIN Platform pl
  ON pl.PlatformID = plos.PlatformID
JOIN PlatformOptions plo
  ON plo.OptionID = plos.OptionID
JOIN PlatformOptionValues plov
  ON plov.OptionID = plos.OptionID
 AND plov.ValueID  = plos.ValueID
ORDER BY c.ClientName, pj.ProjectID, pd.ProductID, pl.PlatformID, po.OptionName, plo.OptionName;


/* ---------------------------------------------------------------------
   5) Days from project order/request date to first approved delivery
      Requires MySQL 8+ (CTE).
   --------------------------------------------------------------------- */
WITH ProjectVersionIDs AS (
  /* Versions used via product */
  SELECT pj.ProjectID, prd.VersionID
  FROM Project pj
  JOIN ProductConfig prc
    ON prc.ProjectID = pj.ProjectID
  JOIN ProductOptionSelection pos
    ON pos.ProductOptionSelectionID = prc.ProductOptionSelectionID
  JOIN ProductDocument prd
    ON prd.ProductID = pos.ProductID

  UNION

  /* Versions used via platform */
  SELECT pj.ProjectID, pld.VersionID
  FROM Project pj
  JOIN PlatformConfig plc
    ON plc.ProjectID = pj.ProjectID
  JOIN PlatformOptionSelection plos
    ON plos.PlatformOptionSelectionID = plc.PlatformOptionSelectionID
  JOIN PlatformDocument pld
    ON pld.PlatformID = plos.PlatformID
),
FirstApproved AS (
  SELECT
    v.ProjectID,
    MIN(at.ApprovalDate) AS DeliveredAt
  FROM ProjectVersionIDs v
  JOIN ApprovalTask at
    ON at.VersionID = v.VersionID
   AND at.`Status` = 'Approved'
  GROUP BY v.ProjectID
)
SELECT
  pj.ProjectID,
  pj.Name AS ProjectName,
  pj.RequestedDate AS OrderDate,
  fa.DeliveredAt   AS FirstApprovedDate,
  TIMESTAMPDIFF(DAY, pj.RequestedDate, fa.DeliveredAt) AS DaysToDelivery
FROM Project pj
JOIN FirstApproved fa
  ON fa.ProjectID = pj.ProjectID
ORDER BY DaysToDelivery DESC;


/* ---------------------------------------------------------------------
   6) Documents that drive value vs potentially drain resources
      Use case: compare project usage vs version churn.
   --------------------------------------------------------------------- */
SELECT
  COUNT(DISTINCT proj.ProjectID) AS ActiveProjects,
  d.DocName,
  CASE
    WHEN COUNT(DISTINCT proj.ProjectID) = 0
      THEN 'Zero Project Usage'
    WHEN COUNT(DISTINCT proj.ProjectID) >= COUNT(DISTINCT dv.VersionID)
      THEN 'Strong Project Usage'
    ELSE 'Low Project Usage'
  END AS DocumentStatus,
  COUNT(DISTINCT dv.VersionID) AS TotalVersions
FROM Document d
LEFT JOIN DocumentVersion dv
  ON d.DocID = dv.DocID
LEFT JOIN ProductDocument pd
  ON dv.VersionID = pd.VersionID
LEFT JOIN PlatformDocument pld
  ON dv.VersionID = pld.VersionID
LEFT JOIN Section s
  ON dv.VersionID = s.VersionID
LEFT JOIN SectionRows sr
  ON s.SectionID = sr.SectionID
LEFT JOIN ChangeLog cl
  ON sr.RowID = cl.RowID
LEFT JOIN Product p
  ON pd.ProductID = p.ProductID
LEFT JOIN ProductOptionSelection pos
  ON p.ProductID = pos.ProductID
LEFT JOIN ProductConfig pc
  ON pos.ProductOptionSelectionID = pc.ProductOptionSelectionID
LEFT JOIN Project proj
  ON pc.ProjectID = proj.ProjectID
GROUP BY d.DocID, d.DocName
ORDER BY ActiveProjects DESC, TotalVersions DESC;


/* ---------------------------------------------------------------------
   7) Roles/users selling the most premium features
      Condition: Seat Material='Leather' AND Infotainment='Premium'
   --------------------------------------------------------------------- */
SELECT DISTINCT
  r.RoleName,
  u.UserName,
  COUNT(DISTINCT p.ProjectID) AS PremiumProjectsCreated,
  p.ProjectID,
  p.Name AS ProjectName
FROM Project p
JOIN `User` u
  ON p.CreatedBy = u.UserID
JOIN Role r
  ON u.RoleID = r.RoleID
JOIN ProductConfig pc1
  ON p.ProjectID = pc1.ProjectID
JOIN ProductOptionSelection pos1
  ON pc1.ProductOptionSelectionID = pos1.ProductOptionSelectionID
JOIN ProductOptionValues pov1
  ON pos1.OptionID = pov1.OptionID AND pos1.ValueID = pov1.ValueID
WHERE (pov1.OptionID = 4 AND pov1.ValueName = 'Leather')
  AND EXISTS (
    SELECT 1
    FROM ProductConfig pc2
    JOIN ProductOptionSelection pos2
      ON pc2.ProductOptionSelectionID = pos2.ProductOptionSelectionID
    JOIN ProductOptionValues pov2
      ON pos2.OptionID = pov2.OptionID AND pos2.ValueID = pov2.ValueID
    WHERE pc2.ProjectID = p.ProjectID
      AND pov2.OptionID = 5 AND pov2.ValueName = 'Premium'
  )
GROUP BY r.RoleName, u.UserName, p.ProjectID, p.Name
ORDER BY r.RoleName, PremiumProjectsCreated DESC;


/* ---------------------------------------------------------------------
   8) Failed company tests: option + value + row content
      Condition: SectionRows.CompanyTestResult='Fail'
   --------------------------------------------------------------------- */
SELECT DISTINCT
  po.OptionName,
  pov.ValueName,
  sr.RowID,
  sr.Content,
  sr.CompanyTestResult
FROM SectionRows sr
JOIN Section s
  ON sr.SectionID = s.SectionID
JOIN DocumentVersion dv
  ON s.VersionID = dv.VersionID
JOIN ProductDocument pd
  ON dv.VersionID = pd.VersionID
JOIN Product pr
  ON pd.ProductID = pr.ProductID
JOIN ProductOptionSelection pos
  ON pos.ProductID = pr.ProductID
JOIN ProductOptionValues pov
  ON pov.ValueID = pos.ValueID AND pov.OptionID = pos.OptionID
JOIN ProductOptions po
  ON po.OptionID = pov.OptionID
WHERE sr.CompanyTestResult = 'Fail';


/* ---------------------------------------------------------------------
   9) Active products and number of configuration links (per car model)
   --------------------------------------------------------------------- */
SELECT
  pr.Name,
  COUNT(p.ProjectID) AS Configuration_Count
FROM Product pr
JOIN ProductOptionSelection ps
  ON ps.ProductID = pr.ProductID
JOIN ProductConfig pc
  ON pc.ProductOptionSelectionID = ps.ProductOptionSelectionID
JOIN Project p
  ON p.ProjectID = pc.ProjectID
WHERE pr.Status = 'Active'
GROUP BY pr.Name
ORDER BY Configuration_Count DESC;


/* ---------------------------------------------------------------------
   10) Objects created by a specific user (UserID = 6)
   --------------------------------------------------------------------- */
SELECT
  'Product' AS ObjectType,
  ProductID AS ObjectID,
  Name      AS ObjectName
FROM Product
WHERE CreatedBy = 6

UNION ALL

SELECT
  'Platform' AS ObjectType,
  PlatformID AS ObjectID,
  Name       AS ObjectName
FROM Platform
WHERE CreatedBy = 6

UNION ALL

SELECT
  'DocumentVersion' AS ObjectType,
  VersionID         AS ObjectID,
  CONCAT('DocID ', DocID, ' — Version ', VersionNum) AS ObjectName
FROM DocumentVersion
WHERE CreatedBy = 6

UNION ALL

SELECT
  'Project' AS ObjectType,
  ProjectID AS ObjectID,
  Name      AS ObjectName
FROM Project
WHERE CreatedBy = 6;


/* ---------------------------------------------------------------------
   11) Gas vs Hybrid projects requiring BOTH:
       Platform 4D Support=True AND Platform Tech Level=High
   --------------------------------------------------------------------- */
SELECT
  e_pov.ValueName AS EngineType,
  COUNT(DISTINCT pr.ProjectID) AS NumProjects
FROM Project pr
JOIN ProductConfig pcfg
  ON pr.ProjectID = pcfg.ProjectID
JOIN ProductOptionSelection pos
  ON pcfg.ProductOptionSelectionID = pos.ProductOptionSelectionID
JOIN ProductOptionValues e_pov
  ON pos.ValueID = e_pov.ValueID AND pos.OptionID = e_pov.OptionID
JOIN ProductOptions e_po
  ON pos.OptionID = e_po.OptionID
WHERE e_po.OptionName = 'Engine'
  AND e_pov.ValueName IN ('Gas','Hybrid')
  AND pr.ProjectID IN (
    SELECT plcfg.ProjectID
    FROM PlatformConfig plcfg
    JOIN PlatformOptionSelection pos2
      ON plcfg.PlatformOptionSelectionID = pos2.PlatformOptionSelectionID
    JOIN PlatformOptionValues pov
      ON pos2.ValueID = pov.ValueID AND pos2.OptionID = pov.OptionID
    JOIN PlatformOptions po
      ON pov.OptionID = po.OptionID
    WHERE (po.OptionName = '4D Support' AND pov.ValueName = 'True')
       OR (po.OptionName = 'Tech Level'  AND pov.ValueName = 'High')
    GROUP BY plcfg.ProjectID
    HAVING COUNT(DISTINCT po.OptionName) = 2
  )
GROUP BY e_pov.ValueName;


/* ---------------------------------------------------------------------
   12) Content changes across document versions (DocID / VersionID / rows)
   --------------------------------------------------------------------- */
SELECT
  dv.DocID,
  dv.VersionID,
  d.DocName,
  s.SectionID,
  sr.RowID,
  sr.Content
FROM DocumentVersion dv
LEFT JOIN Document d
  ON d.DocID = dv.DocID
LEFT JOIN Section s
  ON dv.VersionID = s.VersionID
LEFT JOIN SectionRows sr
  ON s.SectionID = sr.SectionID
ORDER BY dv.DocID, dv.VersionID, s.SectionID, sr.RowID;


/* ---------------------------------------------------------------------
   13) Product document freshness buckets (Very Outdated / Outdated / Up-to-Date)
      Thresholds: >180 days, >90 days, else up-to-date.
   --------------------------------------------------------------------- */
SELECT DISTINCT
  p.Name  AS ProductName,
  p.Status AS ProductStatus,
  d.DocName,
  dv.VersionNum,
  CASE
    WHEN DATEDIFF(CURDATE(), dv.CreationDate) > 180 THEN 'Very Outdated'
    WHEN DATEDIFF(CURDATE(), dv.CreationDate) > 90  THEN 'Outdated'
    ELSE 'Up-to-Date'
  END AS DocumentStatus,
  dv.CreationDate,
  DATEDIFF(CURDATE(), dv.CreationDate) AS DaysOld,
  u.UserName AS CreatedBy
FROM Product p
JOIN ProductDocument pd
  ON p.ProductID = pd.ProductID
JOIN DocumentVersion dv
  ON pd.VersionID = dv.VersionID
JOIN Document d
  ON dv.DocID = d.DocID
JOIN `User` u
  ON dv.CreatedBy = u.UserID
WHERE DATEDIFF(CURDATE(), dv.CreationDate) > 30
ORDER BY
  CASE DocumentStatus
    WHEN 'Very Outdated' THEN 1
    WHEN 'Outdated'      THEN 2
    WHEN 'Up-to-Date'    THEN 3
  END,
  p.Name,
  DaysOld DESC,
  d.DocName;


/* ---------------------------------------------------------------------
   14) Which document has the highest VersionNum (most updated by VersionNum)
      Note: returns all docs whose VersionNum equals the global max.
   --------------------------------------------------------------------- */
SELECT
  dv.DocID,
  d.DocName,
  dv.VersionNum
FROM DocumentVersion dv
JOIN Document d
  ON d.DocID = dv.DocID
WHERE dv.VersionNum = (SELECT MAX(VersionNum) FROM DocumentVersion);


/* ---------------------------------------------------------------------
   15) Approval rate per reviewer (Approved / Decisions)
   --------------------------------------------------------------------- */
SELECT
  u.UserID,
  u.UserName,
  SUM(at.`Status` = 'Approved') AS approved,
  SUM(at.`Status` IN ('Approved','Rejected')) AS decisions,
  ROUND(
    100.0 * SUM(at.`Status` = 'Approved')
    / NULLIF(SUM(at.`Status` IN ('Approved','Rejected')), 0),
    1
  ) AS approval_rate_pct
FROM ApprovalTask at
JOIN `User` u
  ON u.UserID = at.ReviewedBy
GROUP BY u.UserID, u.UserName
ORDER BY approval_rate_pct DESC;


/* ---------------------------------------------------------------------
   16) Most popular product (by distinct projects)
      Requires MySQL 8+ (CTE + window function).
   --------------------------------------------------------------------- */
WITH distinct_projects AS (
  SELECT DISTINCT pc.ProjectID, pos.ProductID
  FROM ProductConfig pc
  JOIN ProductOptionSelection pos
    ON pos.ProductOptionSelectionID = pc.ProductOptionSelectionID
),
grouped_projects AS (
  SELECT
    dp.ProductID,
    pr.Name AS ProductName,
    COUNT(*) AS projects
  FROM distinct_projects dp
  JOIN Product pr
    ON pr.ProductID = dp.ProductID
  GROUP BY dp.ProductID, pr.Name
),
ranked_projects AS (
  SELECT
    ProductID,
    ProductName,
    projects,
    DENSE_RANK() OVER (ORDER BY projects DESC) AS ranked
  FROM grouped_projects
)
SELECT ProductID, ProductName, projects
FROM ranked_projects
WHERE ranked = 1;


/* ---------------------------------------------------------------------
   17) Selected product + platform names per project (and client name)
   --------------------------------------------------------------------- */
SELECT DISTINCT
  proj.Name     AS ProjectName,
  cl.ClientName AS ClientName,
  pr.Name       AS ProductName,
  pl.Name       AS PlatformName
FROM Project proj
JOIN Client cl
  ON proj.ClientID = cl.ClientID
JOIN ProductConfig pr_c
  ON proj.ProjectID = pr_c.ProjectID
JOIN ProductOptionSelection pr_os
  ON pr_c.ProductOptionSelectionID = pr_os.ProductOptionSelectionID
JOIN Product pr
  ON pr_os.ProductID = pr.ProductID
JOIN PlatformConfig pl_c
  ON proj.ProjectID = pl_c.ProjectID
JOIN PlatformOptionSelection pl_os
  ON pl_c.PlatformOptionSelectionID = pl_os.PlatformOptionSelectionID
JOIN Platform pl
  ON pl_os.PlatformID = pl.PlatformID;


/* ---------------------------------------------------------------------
   18) All possible option values for Product + Platform options
   --------------------------------------------------------------------- */
SELECT
  po.OptionName AS OptionName,
  pov.ValueName
FROM ProductOptions po
JOIN ProductOptionValues pov
  ON po.OptionID = pov.OptionID

UNION ALL

SELECT
  po.OptionName AS OptionName,
  pov.ValueName
FROM PlatformOptions po
JOIN PlatformOptionValues pov
  ON po.OptionID = pov.OptionID;


/* ---------------------------------------------------------------------
   19) All option values on product + platform for a specific project
       Example: ProjectID = 1
   --------------------------------------------------------------------- */
SELECT
  proj.Name AS ProjectName,
  p.Name AS ProductPlatformName,
  po.OptionName,
  pov.ValueName
FROM ProductConfig pc
JOIN ProductOptionSelection pos
  ON pc.ProductOptionSelectionID = pos.ProductOptionSelectionID
JOIN Product p
  ON pos.ProductID = p.ProductID
JOIN ProductOptions po
  ON pos.OptionID = po.OptionID
JOIN ProductOptionValues pov
  ON pos.OptionID = pov.OptionID AND pos.ValueID = pov.ValueID
JOIN Project proj
  ON pc.ProjectID = proj.ProjectID
WHERE pc.ProjectID = 1

UNION ALL

SELECT
  proj.Name AS ProjectName,
  pl.Name AS ProductPlatformName,
  plo.OptionName,
  plov.ValueName
FROM PlatformConfig plc
JOIN PlatformOptionSelection plos
  ON plc.PlatformOptionSelectionID = plos.PlatformOptionSelectionID
JOIN Platform pl
  ON plos.PlatformID = pl.PlatformID
JOIN PlatformOptions plo
  ON plos.OptionID = plo.OptionID
JOIN PlatformOptionValues plov
  ON plos.OptionID = plov.OptionID AND plos.ValueID = plov.ValueID
JOIN Project proj
  ON plc.ProjectID = proj.ProjectID
WHERE plc.ProjectID = 1;


/* ---------------------------------------------------------------------
   20) Document updated most often (lowest avg days between versions)
   --------------------------------------------------------------------- */
SELECT
  dv.DocID,
  d.DocName,
  d.Description,
  AVG(TIMESTAMPDIFF(DAY, dv.CreationDate, dv_next.CreationDate)) AS avgDiffDay
FROM DocumentVersion dv
JOIN DocumentVersion dv_next
  ON dv.DocID = dv_next.DocID
 AND dv.CreationDate < dv_next.CreationDate
 AND NOT EXISTS (
   SELECT 1
   FROM DocumentVersion x
   WHERE x.DocID = dv.DocID
     AND x.CreationDate > dv.CreationDate
     AND x.CreationDate < dv_next.CreationDate
 )
JOIN Document d
  ON dv.DocID = d.DocID
GROUP BY dv.DocID, d.DocName, d.Description
ORDER BY avgDiffDay ASC;


/* ---------------------------------------------------------------------
   21) Top 5 clients by project count (loyalty proxy)
   --------------------------------------------------------------------- */
SELECT
  c.ClientID,
  c.ClientName,
  COUNT(pj.ProjectID) AS ProjectCount
FROM Client c
JOIN Project pj
  ON c.ClientID = pj.ClientID
GROUP BY c.ClientID, c.ClientName
ORDER BY ProjectCount DESC
LIMIT 5;


/* ---------------------------------------------------------------------
   22) Projects with N/A test results (Product-side OR Platform-side)
   --------------------------------------------------------------------- */
SELECT DISTINCT
  pj.ProjectID,
  pj.Name AS ProjectName,
  sr.RowID,
  sr.CompanyTestResult,
  sr.ClientTestResult
FROM Project pj
JOIN ProductConfig prc
  ON prc.ProjectID = pj.ProjectID
JOIN ProductOptionSelection pos
  ON pos.ProductOptionSelectionID = prc.ProductOptionSelectionID
JOIN ProductDocument prd
  ON prd.ProductID = pos.ProductID
JOIN Section s
  ON s.VersionID = prd.VersionID
JOIN SectionRows sr
  ON sr.SectionID = s.SectionID
WHERE sr.ClientTestResult = 'N/A'
   OR sr.CompanyTestResult = 'N/A'

UNION

SELECT DISTINCT
  pj.ProjectID,
  pj.Name AS ProjectName,
  sr.RowID,
  sr.CompanyTestResult,
  sr.ClientTestResult
FROM Project pj
JOIN PlatformConfig plc
  ON plc.ProjectID = pj.ProjectID
JOIN PlatformOptionSelection plos
  ON plos.PlatformOptionSelectionID = plc.PlatformOptionSelectionID
JOIN PlatformDocument pld
  ON pld.PlatformID = plos.PlatformID
JOIN Section s
  ON s.VersionID = pld.VersionID
JOIN SectionRows sr
  ON sr.SectionID = s.SectionID
WHERE sr.ClientTestResult = 'N/A'
   OR sr.CompanyTestResult = 'N/A';
