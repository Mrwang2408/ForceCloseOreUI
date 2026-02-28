add_rules("mode.debug", "mode.release")

add_repositories("liteldev-repo https://github.com/LiteLDev/xmake-repo.git")
if is_plat("windows") then
    add_requires("detours v4.0.1-xmake.1")
elseif is_plat("android") then   

end
add_requires("nlohmann_json v3.11.3")

target("ForceCloseOreUI")
    set_kind("shared")
    add_files("src/**.cpp")
    add_includedirs("src")
    set_languages("c++20")
    set_strip("all")
    add_linkdirs("lib")
    add_packages("nlohmann_json")
    if is_plat("windows") then
        add_packages("detours")
        remove_files("src/api/memory/android/**.cpp","src/api/memory/android/**.h")
        add_cxflags("/utf-8", "/EHa")
    elseif is_plat("android") then
        remove_files("src/api/memory/win/**.cpp","src/api/memory/win/**.h")

        -- Size-focused compiler flags (conservative / generally safe)
        -- Use -Oz (optimize for size) and put functions/data in separate sections so
        -- the linker can garbage-collect unused code/data.
        add_cflags("-Oz", "-ffunction-sections", "-fdata-sections", "-fvisibility=hidden")
        add_cxxflags("-Oz", "-ffunction-sections", "-fdata-sections", "-fvisibility=hidden")

        -- Enable ThinLTO for better cross-translation-unit size optimization when supported.
        -- Note: LTO may increase build memory/time; keep as an option.
        add_cflags("-flto=thin")
        add_cxxflags("-flto=thin")

        -- Linker flags: remove unused sections, do identical code folding where supported, and strip
        -- symbols at link time (release build already strips via set_strip("all")).
        add_ldflags("-Wl,--gc-sections", "-Wl,--icf=all", "-Wl,-s")

        -- Keep existing project-specific CXXFLAGS and links
        add_cxxflags("-DLLVM_TARGETS_TO_BUILD=\"ARM;AArch64;BPF\"")
        add_links("GlossHook")
    end