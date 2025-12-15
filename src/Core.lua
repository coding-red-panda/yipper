-- Yipper - Core Module
--
-- Defines the core of the Yipper AddOn and ensures that our one and only global "Yipper" has been defined
-- as a constant, referencing the shared AddOn table that we can access between files.
-- Since this is the main entry point, we will define and assigned Yipper, allowing the core methods to
-- define all the required methods needed.
local _, addonTable = ...

Yipper = addonTable or { } -- Just in case nothing has been declared for Yipper.
