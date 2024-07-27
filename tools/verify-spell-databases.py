import os
import json

FILE_LOC = os.path.abspath(os.path.dirname(__file__))


def main():
    database_dir = os.path.join(FILE_LOC, "..", "databases", "base")
    base_spell_descriptions = os.path.join(database_dir, "spell-descriptions.json")
    base_spells_by_class = os.path.join(database_dir, "spells-by-class.json")

    with open(base_spell_descriptions, "r") as f:
        descriptions = json.load(f)
    with open(base_spells_by_class, "r") as f:
        by_class = json.load(f)

    spell_levels = [
        "Cantrips",
        "1st Level",
        "2nd Level",
        "3rd Level",
        "4th Level",
        "5th Level",
        "6th Level",
        "7th Level",
        "8th Level",
        "9th Level",
    ]
    all_spells_by_class = set()
    for class_ in by_class.keys():
        for level in spell_levels:
            for spell in by_class[class_][level]:
                all_spells_by_class.add(spell)

    any_missing: bool = False
    for spell in all_spells_by_class:
        if spell not in descriptions.keys():
            print(
                f"{spell} not in descriptions! Godot will error if description is requested."
            )
            any_missing = True

    if not any_missing:
        print("All spells are accounted for!")


if __name__ == "__main__":
    main()
