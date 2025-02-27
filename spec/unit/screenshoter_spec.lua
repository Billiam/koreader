describe("ReaderScreenshot module", function()
    local DataStorage, DocumentRegistry, ReaderUI, lfs, UIManager, Event, Screen
    local sample_epub = "spec/front/unit/data/leaves.epub"
    local readerui
    setup(function()
        require("commonrequire")
        DataStorage = require("datastorage")
        DocumentRegistry = require("document/documentregistry")
        ReaderUI = require("apps/reader/readerui")
        lfs = require("libs/libkoreader-lfs")
        UIManager = require("ui/uimanager")
        Event = require("ui/event")
        Screen = require("device").screen

        readerui = ReaderUI:new{
            dimen = Screen:getSize(),
            document = DocumentRegistry:openDocument(sample_epub),
        }
    end)

    teardown(function()
        readerui:handleEvent(Event:new("SetRotationMode", Screen.DEVICE_ROTATED_UPRIGHT))
        readerui:closeDocument()
        readerui:onClose()
    end)

    it("should get screenshot in portrait", function()
        local name = DataStorage:getDataDir() .. "/screenshots/reader_screenshot_portrait.png"
        readerui:handleEvent(Event:new("SetRotationMode", Screen.DEVICE_ROTATED_UPRIGHT))
        UIManager:quit()
        UIManager:show(readerui)
        UIManager:scheduleIn(1, function()
            UIManager:close(readerui)
            -- We haven't torn it down yet
            ReaderUI.instance = readerui
        end)
        UIManager:run()
        readerui.screenshot:onScreenshot(name)
        assert.truthy(lfs.attributes(name, "mode"))
        UIManager:quit()
    end)

    it("should get screenshot in landscape", function()
        local name = DataStorage:getDataDir() .. "/screenshots/reader_screenshot_landscape.png"
        readerui:handleEvent(Event:new("SetRotationMode", Screen.DEVICE_ROTATED_CLOCKWISE))
        UIManager:quit()
        UIManager:show(readerui)
        UIManager:scheduleIn(2, function()
            UIManager:close(readerui)
            -- We haven't torn it down yet
            ReaderUI.instance = readerui
        end)
        UIManager:run()
        readerui.screenshot:onScreenshot(name)
        assert.truthy(lfs.attributes(name, "mode"))
        UIManager:quit()
    end)
end)
