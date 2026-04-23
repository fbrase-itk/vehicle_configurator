## Data

### Domain model

A **configuration** is a tuple of catalog references plus a set of
equipment items. An **order** is a configuration with customer contact
data and a snapshotted total.

```
CarModel 1 ─── n EngineOption
                         │
          CarModel ──┐   │
          Paint      │   │
          WheelDesign├───┼── Configuration ─── 0..5 SpecialEquipment
          WheelColor │   │     (UUID PK)
          Caliper    │   │        │
                         │        └── n Order
```

### Tables

All IDs are `INT AUTO_INCREMENT` except `configurations.id`, which is a
`VARCHAR(36)` UUID. Money columns are `DECIMAL(10,2)` in EUR.

| Table | Key columns | Notes |
|-------|-------------|-------|
| `car_models` | `id`, `brand`, `name`, `model_file`, `base_price`, `description` | Seeded: one row today (Aventador LP700-4). |
| `engine_options` | `id`, `car_model_id` (FK), `name`, `horsepower`, `price` | Engines are **per-model** (enforced via FK). |
| `paint_options` | `id`, `name`, `color_code`, `price` | HTML color codes used by the UI swatches and the 3D body material. |
| `wheel_designs` | `id`, `name`, `model_object`, `price` | `model_object` matches a mesh in the GLB (`Obj_Rim_T0A` / `Obj_Rim_T0B`). |
| `wheel_colors` | `id`, `name`, `color_code`, `price` | Independent of design. |
| `caliper_colors` | `id`, `name`, `color_code`, `price` | |
| `special_equipment` | `id`, `name`, `description`, `price` | Five rows seeded. |
| `configurations` | `id VARCHAR(36) PK (UUID)`, FKs to all six catalog tables, `created_at` | Created by `POST /api/configurations`. |
| `configuration_equipment` | `configuration_id` (FK), `equipment_id` (FK), composite PK | Many-to-many; UI-capped at 5 rows per configuration. |
| `orders` | `id`, `configuration_id` (FK, NOT NULL), `customer_name`, `customer_email`, `total_price`, `created_at` | `total_price` is snapshotted server-side. |

### Pricing

The authoritative formula lives in
`ConfiguratorService.calculateTotalPrice`:

```
total = carModel.basePrice
      + engine.price
      + paint.price
      + wheelDesign.price
      + wheelColor.price
      + caliperColor.price
      + Σ equipment.price
```

Computed in Java as `BigDecimal` (no floating-point money).
Formatted client-side with `Intl.NumberFormat('de-DE', …currency: 'EUR')`.

### Seed data

The initial seed is embedded in `database/init/001-init.sql`:

- **1** car model (*Lamborghini Aventador LP700-4*, €362 199.40 base).
- **4** engines tied to that model (LP700 / LP720 / LP750 SV / LP770 SVJ).
- **8** paint colors.
- **2** wheel designs (mapping to the two rim meshes in the GLB).
- **3** wheel colors, **4** caliper colors.
- **5** special equipment items.

No seeded configurations or orders.
