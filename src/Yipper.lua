-- Yipper - Main Addon
--
-- This is loaded as last entry in the chain and should have everything defined at this point.
-- Thanks to WoW passing the main table, and our AddOn having defined the Yipper constant.

-- Parent Frame
--
-- The parent frame of our AddOn. This frame will be used to contain everything our AddOn does,
-- and is passed around as argument when initializing the AddOn on load.
local frame = CreateFrame("Frame", "Yipper", ParentUI,  BackdropTemplateMixin and "BackdropTemplate")

-- Initialize the AddOn and let the code take over.
Yipper.UI:Init(frame)
