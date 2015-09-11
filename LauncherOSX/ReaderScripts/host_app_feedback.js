//  LauncherOSX
//
//  Created by Boris Schneiderman.
//
//  Copyright (c) 2014 Readium Foundation and/or its licensees. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//  3. Neither the name of the organization nor the names of its contributors may be
//  used to endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.

$(document).ready(function()
                  {
                  console.log("DOM READY");
require(["readium_shared_js/globalsSetup"], function ()
        {
        console.log("globalsSetup READY");
require(['readium_shared_js/views/reader_view'], function (ReaderView)
        {
        console.log("reader_view READY");
        
//        require(['readium_plugin_annotations'], function (annotations)
//                {
//                
//                console.log(annotations);
//                
//                console.log(ReadiumSDK);
//                console.log(ReadiumSDK.reader);
//                console.log(ReadiumSDK.reader.plugins);
////                console.log(ReadiumSDK.reader.plugins.annotations);
//
//                });
        
    ReadiumSDK.HostAppFeedback = function()
    {

        var initNavigatorEpubReadingSystem = function()
        {

            // Adjust to taste (application/vendor -level metadata):
            window.navigator.epubReadingSystem.name = "Readium SDKLauncher-OSX";
            window.navigator.epubReadingSystem.version = "1.0.0";

            // Readium "internal" version:
            ReadiumSDK.READIUM_version = "1.0.0";

            // Do not edit the following lines! (low-level metadata)
            // The templated values ("ReadiumSDK.READIUM_"-prefixed values) are auto-generated by the build script,
            // see the "epubReadingSystem.js" file.

            window.navigator.epubReadingSystem.readium = {};
            window.navigator.epubReadingSystem.readium.buildInfo = {};

            window.navigator.epubReadingSystem.readium.buildInfo.dateTime = ReadiumSDK.READIUM_dateTimeString;
            //new Date(timestamp).toString();

            window.navigator.epubReadingSystem.readium.buildInfo.version = ReadiumSDK.READIUM_version;

            window.navigator.epubReadingSystem.readium.buildInfo.gitRepositories = [];

            var repo1 = {};
            repo1.name = "SDKLauncher-OSX";
            repo1.sha = ReadiumSDK.READIUM_OSX_sha;
            repo1.tag = ReadiumSDK.READIUM_OSX_tag;
            repo1.clean = ReadiumSDK.READIUM_OSX_clean;

            repo1.version = ReadiumSDK.READIUM_OSX_version;
            repo1.branch = ReadiumSDK.READIUM_OSX_branch;
            repo1.release = ReadiumSDK.READIUM_OSX_release;
            repo1.timestamp = ReadiumSDK.READIUM_OSX_timestamp;

            repo1.url = "https://github.com/readium/" + repo1.name + "/tree/" + repo1.sha;
            window.navigator.epubReadingSystem.readium.buildInfo.gitRepositories.push(repo1);

            var repo2 = {};
            repo2.name = "readium-sdk";
            repo2.sha = ReadiumSDK.READIUM_SDK_sha;
            repo2.tag = ReadiumSDK.READIUM_SDK_tag;
            repo2.clean = ReadiumSDK.READIUM_SDK_clean;

            repo2.version = ReadiumSDK.READIUM_SDK_version;
            repo2.branch = ReadiumSDK.READIUM_SDK_branch;
            repo2.release = ReadiumSDK.READIUM_SDK_release;
            repo2.timestamp = ReadiumSDK.READIUM_SDK_timestamp;

            repo2.url = "https://github.com/readium/" + repo2.name + "/tree/" + repo2.sha;
            window.navigator.epubReadingSystem.readium.buildInfo.gitRepositories.push(repo2);

            var repo3 = {};
            repo3.name = "readium-shared-js";
            repo3.sha = ReadiumSDK.READIUM_SHARED_JS_sha;
            repo3.tag = ReadiumSDK.READIUM_SHARED_JS_tag;
            repo3.clean = ReadiumSDK.READIUM_SHARED_JS_clean;

            repo3.version = ReadiumSDK.READIUM_SHARED_JS_version;
            repo3.branch = ReadiumSDK.READIUM_SHARED_JS_branch;
            repo3.release = ReadiumSDK.READIUM_SHARED_JS_release;
            repo3.timestamp = ReadiumSDK.READIUM_SHARED_JS_timestamp;

            repo3.url = "https://github.com/readium/" + repo3.name + "/tree/" + repo3.sha;
            window.navigator.epubReadingSystem.readium.buildInfo.gitRepositories.push(repo3);

            // Debug check:
            //console.debug(JSON.stringify(window.navigator.epubReadingSystem, undefined, 2));
        };

        ReadiumSDK.on(ReadiumSDK.Events.READER_INITIALIZED, function()
        {

            initNavigatorEpubReadingSystem();

            ReadiumSDK.reader.on(ReadiumSDK.Events.PAGINATION_CHANGED, this.onPaginationChanged, this);
            ReadiumSDK.reader.on(ReadiumSDK.Events.SETTINGS_APPLIED, this.onSettingsApplied, this);
            ReadiumSDK.reader.on(ReadiumSDK.Events.MEDIA_OVERLAY_STATUS_CHANGED, this.onMediaOverlayStatusChanged, this);
            ReadiumSDK.reader.on(ReadiumSDK.Events.MEDIA_OVERLAY_TTS_SPEAK, this.onMediaOverlayTTSSpeak, this);
            ReadiumSDK.reader.on(ReadiumSDK.Events.MEDIA_OVERLAY_TTS_STOP, this.onMediaOverlayTTSStop, this);

            window.LauncherUI.onReaderInitialized();

        }, this);

        this.onPaginationChanged = function(pageChangeData)
        {

            if (window.LauncherUI)
            {
                window.LauncherUI.onOpenPage(JSON.stringify(pageChangeData.paginationInfo), JSON.stringify(
                {
                    canGoLeft: pageChangeData.paginationInfo.canGoLeft(),
                    canGoRight: pageChangeData.paginationInfo.canGoRight()
                }));
            }
        };

        this.onSettingsApplied = function()
        {

            if (window.LauncherUI)
            {
                window.LauncherUI.onSettingsApplied();
            }
        };

        this.onMediaOverlayStatusChanged = function(status)
        {

            if (window.LauncherUI)
            {
                window.LauncherUI.onMediaOverlayStatusChanged(JSON.stringify(status));
            }
        };

        this.onMediaOverlayTTSSpeak = function(tts)
        {

            if (window.LauncherUI)
            {
                window.LauncherUI.onMediaOverlayTTSSpeak(JSON.stringify(tts));
            }
        };

        this.onMediaOverlayTTSStop = function()
        {

            if (window.LauncherUI)
            {
                window.LauncherUI.onMediaOverlayTTSStop();
            }
        };
    }();


    var opts = {
        needsFixedLayoutScalerWorkAround: true,
        el: "#viewport",
        annotationCSSUrl: '/readium_Annotations.css' //prefix + '/css/annotations.css'
    };

    ReadiumSDK.on(ReadiumSDK.Events.PLUGINS_LOADED, function(reader)
                  {
                  // readium built-in (should have been require()'d outside this scope)
                  console.log(reader.plugins.annotations);
                  if (reader.plugins.annotations) {
                    reader.plugins.annotations.initialize({annotationCSSUrl: opts.annotationCSSUrl});
                    reader.plugins.annotations.on("annotationClicked", function(type, idref, cfi, id) {
                                                    console.log("ANNOTATION CLICK: " + id);
                                                    reader.plugins.annotations.removeHighlight(id);
                                                    });
                    reader.plugins.annotations.on("textSelectionEvent", function() {
                                                    console.log("ANNOTATION SELECT");
                                                    reader.plugins.annotations.addSelectionHighlight(Math.floor((Math.random()*1000000)), "highlight");
                                                    });
                  }
                  
        // external (require()'d via Dependency Injection, see examplePluginConfig function parameter passed above)
        console.log(reader.plugins.example);
    });
        

        //var prefix = (self.location && self.location.origin && self.location.pathname) ? (self.location.origin + self.location.pathname + "/..") : "";

        ReadiumSDK.reader = new ReaderView(opts);
        
        console.log("DONE READER");

        //Globals.emit(Globals.Events.READER_INITIALIZED, ReadiumSDK.reader);
        ReadiumSDK.emit(ReadiumSDK.Events.READER_INITIALIZED, ReadiumSDK.reader);
    });
});
});
