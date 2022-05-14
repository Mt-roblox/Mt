local MtEnum = {

	Direction = {
		Left  = "Left",
		Right = "Right",
		Up    = "Up",
		Down  = "Down",
	},

	Side       = {
		Left   = "Left",
		Right  = "Right",
		Top    = "Top",
		Bottom = "Bottom"
	},

	ResizeSide = {
		-- internal use
		-- "oh, so that's why it's in numbers."

		None   = 0,

		Left   = 1,
		Top    = 1,
		Right  = 2,
		Bottom = 2
	},

	Orientation    = {
		Horizontal = "Horizontal",
		Vertical   = "Vertical",
		Diagonal   = "Diagonal",

		DiagonalRight = "DRight",
		DiagonalLeft  = "DLeft",
	},
	
	WindowInteractionState = {
		None               = "None",
		Moving             = "Moving",
		Resizing           = "Resizing"
	},

	WindowHandleStyle = {
		Windows       = "Windows",
		MacOS         = "MacOS",
		WindowsDialog = "WindowsDialog",
		MacOSDialog   = "MacOSDialog",
	},

}

return MtEnum