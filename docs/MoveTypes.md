# Move Type Documentation

### 1. Entrada
**Scenario**: When a container is brought into the yard.

- **Location Requirements**:
  - A location must be assigned, and it should be marked as unavailable.
  - The location must be available before assigning it, validated through `location_must_be_available`.
- **Previous Location**: Not applicable.
- **Current Location**: Made unavailable after the move is saved.

- **Behavior**:
  - Only one `Entrada` is allowed per container.
  - Other moves are only allowed if an `Entrada` already exists for that container.

---

### 2. Salida
**Scenario**: When a container is removed from the yard.

- **Location Requirements**:
  - A location is optional; if specified, it will be made available upon move creation.
- **Previous Location**: Not applicable.
- **Current Location**: Made available after the move is saved.

- **Behavior**:
  - Only one `Salida` is allowed per container.
  - No moves are permitted after a `Salida` for that container.

---

### 3. Reacomodo
**Scenario**: A container is repositioned within the yard.

- **Location Requirements**:
  - A new location is optional. However, if a new location is specified, the previous location should be marked as available, and the new location should be marked as unavailable.
- **Previous Location**: Made available upon move creation.
- **Current Location**: Made unavailable after the move is saved.

- **Behavior**:
  - Repositions the container without changing its yard entry/exit status.
  - `location_must_be_available` validation ensures availability before assigning.

---

### 4. Traspaleo
**Scenario**: Internal yard movement where the container is transferred but may stay at the same location.

- **Location Requirements**:
  - Location change is optional.
  - If changed, the previous location becomes available, and the new one is marked unavailable.
- **Previous Location**: Made available only if the location changes.
- **Current Location**: Made unavailable if changed.

- **Behavior**:
  - Uses the helper method `location_changed_for_types?` to check if the location is modified.
  - Ensures flexibility for the container’s position.

---

### 5. Lavado
**Scenario**: The container is cleaned, possibly at a new location.

- **Location Requirements**:
  - Like `Traspaleo`, changing the location is optional.
  - If the location changes, the old one becomes available, and the new one is marked unavailable.
- **Previous Location**: Made available only if there’s a location change.
- **Current Location**: Marked unavailable if modified.

- **Behavior**:
  - Utilizes `location_changed_for_types?` to determine if location update actions are needed.
  - Supports flexibility in location assignment during cleaning operations.

---

### Callback Summary

- **location_changed_for_types?**:
  - Determines if location adjustments should be applied for `Traspaleo` or `Lavado` by checking whether the location was altered.

- **mark_previous_location_available**:
  - Ensures the previous location is made available if the location changes in `Reacomodo`, `Traspaleo`, or `Lavado`.

- **mark_location_unavailable**:
  - Makes the current location unavailable after save for `Entrada`, `Reacomodo`, or when the location is updated in `Traspaleo` or `Lavado`.

- **mark_location_available**:
  - Frees up the location if the move is a `Salida` or upon destruction.
