return {
	"monaqa/dial.nvim",
	opts = function(_, opts)
		local augend = require("dial.augend")

		-- C++ gets its own, number-only group.
		--
		-- The old implementation called
		-- `register_group({ default = base, cpp = base })`, which *replaced*
		-- LazyVim's default group (losing dates, months, ordinals, hex
		-- colours and and/or cycling) and registered a `cpp` group that
		-- nothing ever referenced, because `dials_by_ft` had no `cpp` key.
		local cpp_group = {
			augend.integer.alias.decimal,
			augend.integer.alias.hex,
			augend.integer.alias.decimal_int,
			augend.integer.alias.octal,
			augend.integer.alias.binary,
			augend.constant.alias.bool,
		}

		opts.groups = opts.groups or {}
		-- A copy, because LazyVim appends the default group to every other
		-- group (in place) and that would empty `cpp_group` of its purpose.
		opts.groups.cpp = { unpack(cpp_group) }

		opts.dials_by_ft = opts.dials_by_ft or {}
		opts.dials_by_ft.cpp = "cpp"

		-- LazyVim copies the default group into every other group, so
		-- re-register the (reduced) cpp group afterwards to restore it.
		vim.schedule(function()
			local config = require("dial.config")
			config.augends:register_group({ cpp = { unpack(cpp_group) } })
		end)

		return opts
	end,
}
