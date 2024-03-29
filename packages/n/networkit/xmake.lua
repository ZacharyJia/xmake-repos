package("networkit")
    set_homepage("https://networkit.github.io")
    set_description("NetworKit is a growing open-source toolkit for large-scale network analysis.")
    set_license("MIT")

    -- add_urls("https://github.com/networkit/networkit/archive/refs/tags/$(version).tar.gz",
    --          "https://github.com/networkit/networkit.git")

    -- 只能用git下载，因为release的tar.gz文件不包含子模块
    add_urls("https://github.com/networkit/networkit.git")

    add_versions("10.1", "35d11422b731f3e3f06ec05615576366be96ce26dd23aa16c8023b97f2fe9039")
    add_patches("10.1", path.join(os.scriptdir(), "patches", "10.1", "cmakelists.patch"), "d6e91b928e92907ed9028fa345a55e69c141c38bf57a8e188c5d077cd223717f")

    add_deps("cmake")
    add_deps("openmp")

    add_links("networkit")

    on_download(function (package, opt)
        local url = opt.url
        local sourcedir = opt.sourcedir
        -- 如果目录已经存在，就删掉重新下载
        if os.isdir(sourcedir) then
            os.rm(sourcedir)
        end

        import("devel.git")
        git.clone(url, {depth = 1, branch = "release-" .. package:version_str(), outputdir = sourcedir, recursive = true})
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DNETWORKIT_STATIC=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DNETWORKIT_STATIC=ON")
        end
        -- table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("NetworKit::Graph", {includes = "networkit/graph/Graph.hpp", configs = {languages = "c++17"}}))
    end)
