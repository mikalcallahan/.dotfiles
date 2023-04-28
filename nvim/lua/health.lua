 local config = require("lspconfig")
 local _local_1_ = vim.health local report_start_21 = _local_1_["report_start"]
 local report_info_21 = _local_1_["report_info"]
 local report_ok_21 = _local_1_["report_ok"]
 local report_warn_21 = _local_1_["report_warn"]
 local report_error_21 = _local_1_["report_error"]

 local function spaces(amount) _G.assert((nil ~= amount), "Missing argument amount on /Users/mikal/.config/nvim/fnl/modules/editor/hotpot/+reflect/config.fnl:8")
 local _2_ do local tbl_17_auto = {} local i_18_auto = #tbl_17_auto for i = 0, amount do local val_19_auto = " " if (nil ~= val_19_auto) then i_18_auto = (i_18_auto + 1) do end (tbl_17_auto)[i_18_auto] = val_19_auto else end end _2_ = tbl_17_auto end return table.concat(_2_, "") end


 local function report_21(name, max_name_length) _G.assert((nil ~= max_name_length), "Missing argument max-name-length on /Users/mikal/.config/nvim/fnl/modules/editor/hotpot/+reflect/config.fnl:12") _G.assert((nil ~= name), "Missing argument name on /Users/mikal/.config/nvim/fnl/modules/editor/hotpot/+reflect/config.fnl:12")
 assert(("string" == type(name)), "expected string for name")
 assert(("number" == type(max_name_length)), "expected number for max-name-length")

 local command do local t_4_ = config if (nil ~= t_4_) then t_4_ = (t_4_)[name] else end if (nil ~= t_4_) then t_4_ = (t_4_).cmd else end if (nil ~= t_4_) then t_4_ = (t_4_)[1] else end command = t_4_ end
 local spaces0 = spaces((max_name_length - name:len()))
 if __fnl_global__nil_3f(command) then
 return report_warn_21(string.format("%s %sthe command is not defined.", spaces0, name)) elseif __fnl_global__executable_3f(command) then


 return report_ok_21(string.format("%s %s`%s` is executable.", name, spaces0, command)) else

 return report_error_21(string.format("%s %s`%s` is not executable.", name, spaces0, command)) end end


 local function check_21()
 report_start_21("LSP server executables")
 local configured_servers = config.available_servers() local configured_servers0
 do table.sort(configured_servers) configured_servers0 = configured_servers end local max_name_length

 do local max = 0 for _, name in ipairs(configured_servers0) do
 if (name:len() > max) then max = name:len() else max = max end end max_name_length = max end
 if (0 == #configured_servers0) then
 return report_info_21("no lsp servers have been configured.") else
 for _, server in ipairs(configured_servers0) do
 report_21(server, max_name_length) end return nil end end

 return {check = check_21}