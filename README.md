# DarkLightToggle.nvim

Tested with archlinux (should work on any linux and mb on macos).  
Tested with nvim 0.9.0.  
_There is an alternative branch named "without\_timer" to use it with job (I don't know if it can help for nvim version compatibility)_

**Packer**
```lua
use
{
  'ninofaivre/DarkLightToggle.nvim',
  config = function () require("DarkLightToggle").setup("dayfox", "nightfox", { ["start"] = { hour = 6 }, ["end"] = { hour = 20 } }) end
}
```

setup function take day colorscheme and night colorscheme as first and second parameter.  
The third param is a table with a "start" and "end" as tables. Each of this table take at least "hour" as argument and can optionaly take "min" and "sec".
On both versions there is a safety feature if setup is called multiple times (_it stop the job or the timer_) so you can call setup multiple time without any fear.
<br/>
<br/>
<br/>
This plugin should work even if using nvim multiple days without restarting it.

TO-DO :
- [ ] daylight saving time (_currently it should be wrong the first time because of the timer but should work back after_)
