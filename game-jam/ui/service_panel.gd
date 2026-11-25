extends PanelContainer

signal drink_selected(index: int)
signal dismissed

@onready var items: GridContainer = %Items
@onready var scroll: ScrollContainer = %Scroll

var shown_phase: StringName


func _ready() -> void:
	%Dismiss.pressed.connect(dismissed.emit)
	%Continue.pressed.connect(dismissed.emit)
	scroll.resized.connect(_fit_columns)
	visibility_changed.connect(_on_visibility_changed)
	_fit_columns()


func present(director: DateDirector, balance: int) -> void:
	var ordering := director.phase == &"ordering"
	var entering := shown_phase != director.phase
	shown_phase = director.phase
	scroll.visible = ordering
	%Dismiss.visible = ordering
	%Reaction.visible = not ordering
	%Affinity.visible = not ordering
	var guest := director.profile.display_name
	if ordering:
		%Heading.text = "CAMARERO"
		%Prompt.text = "¿Qué te pongo para %s?" % guest
		if entering:
			_build_cards(director.drink_menu)
			scroll.scroll_vertical = 0
		for card: Button in items.get_children():
			var drink := director.drink_menu.get_drink(card.get_meta(&"drink_index"))
			_set_price(card, drink.price, balance)
	else:
		%Heading.text = guest.to_upper()
		%Prompt.text = "%s para %s" % [director.last_drink.display_name, guest]
		%Reply.text = "«%s»" % director.gift_reply
		%Affinity.text = "AFINIDAD +%d" % director.gift_gain if director.gift_gain > 0 else "AFINIDAD SIN CAMBIOS"
	if entering:
		var focus_target: Button = %Dismiss if ordering else %Continue
		focus_target.grab_focus()


func _build_cards(menu: DrinkMenu) -> void:
	for old_card in items.get_children():
		items.remove_child(old_card)
		old_card.queue_free()
	for index in menu.drinks.size():
		var drink := menu.get_drink(index)
		if drink == null:
			continue
		var card := %CardTemplate.duplicate() as Button
		card.unique_name_in_owner = false
		card.name = "Drink%d" % index
		card.set_meta(&"drink_index", index)
		items.add_child(card)
		card.visible = true
		card.get_node("Inset/Row/Art/Icon").kind = drink.icon_kind
		card.get_node("Inset/Row/Details/Name").text = drink.display_name
		var tasting_note: Label = card.get_node("Inset/Row/Details/Description")
		tasting_note.text = drink.description
		tasting_note.visible = not drink.description.is_empty()
		card.tooltip_text = (drink.display_name + "\n" + drink.description).strip_edges()
		card.accessibility_name = "%s, %d monedas" % [drink.display_name, drink.price]
		card.pressed.connect(drink_selected.emit.bind(index))


func _set_price(card: Button, price: int, balance: int) -> void:
	var price_label: Label = card.get_node("Inset/Row/Details/Price")
	card.disabled = price > balance
	card.mouse_default_cursor_shape = Control.CURSOR_ARROW if card.disabled else Control.CURSOR_POINTING_HAND
	card.get_node("Inset/Row/Art").modulate.a = 0.6 if card.disabled else 1.0
	price_label.text = "%d monedas" % price
	if card.disabled:
		price_label.text += " · Faltan %d" % (price - balance)


func _fit_columns() -> void:
	items.columns = clampi(floori(scroll.size.x / 235.0), 1, 3)


func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		shown_phase = &""
