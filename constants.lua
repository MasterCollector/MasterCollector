local MasterCollector = select(2,...)
local Constants = {}
MasterCollector.Constants = Constants

Constants.ItemSubclassEnumEnumToBaseSkill = {
	[Enum.ItemRecipeSubclass.Alchemy] = 171,
	[Enum.ItemRecipeSubclass.Blacksmithing] = 164,
	[Enum.ItemRecipeSubclass.Cooking] = 185,
	[Enum.ItemRecipeSubclass.Enchanting] = 333,
	[Enum.ItemRecipeSubclass.Engineering] = 202,
	[Enum.ItemRecipeSubclass.FirstAid] = 129,
	[Enum.ItemRecipeSubclass.Fishing] = 356,
	[Enum.ItemRecipeSubclass.Inscription] = 773,
	[Enum.ItemRecipeSubclass.Jewelcrafting] = 755,
	[Enum.ItemRecipeSubclass.Leatherworking] = 165,
	[Enum.ItemRecipeSubclass.Tailoring] = 197,
}

Constants.SpellIDsForRefresh = {
	[176111] = true -- Time Travelling (Blasted Lands iron horde)
}

