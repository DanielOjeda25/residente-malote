## item_data.gd
## Resource que define las propiedades de un item.
## Crear items como archivos .tres en resources/items/

extends Resource
class_name ItemData

enum ItemType { WEAPON, AMMO, HEALING, KEY_ITEM, COMBINABLE }

@export var item_id: String = ""
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var type: ItemType = ItemType.KEY_ITEM
@export var icon: Texture2D = null
@export var model_scene: PackedScene = null  # Para vista 3D en inventario
@export var stackable: bool = false
@export var max_stack: int = 1
@export var use_effect: String = ""  # Nombre del efecto al usar

# Para items combinables
@export var combine_with_id: String = ""  # ID del item con el que se combina
@export var combine_result_id: String = ""  # ID del item resultante

# Para armas
@export var damage: int = 0
@export var ammo_type: String = ""  # ID del tipo de munición que usa

# Para curación
@export var heal_amount: int = 0
