{filterLists}: {
  policies = {
    "{4b7825da-0dd1-44f9-9717-bee5b2408af6}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4641852/always_visible-0.4.6.xpi";
      installation_mode = "force_installed";
    };
    "reddit-unhider@siddh.dev" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4813095/reddit_unhider-1.0.4.xpi";
      installation_mode = "force_installed";
    };
    "addon@darkreader.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      installation_mode = "force_installed";
    };
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };
    "sponsorBlocker@ajay.app" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      installation_mode = "force_installed";
    };
    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
      installation_mode = "force_installed";
    };
    "firefox-extension@steamdb.info" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
      installation_mode = "force_installed";
    };
    "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/augmented-steam/latest.xpi";
      installation_mode = "force_installed";
    };
    "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
      installation_mode = "force_installed";
    };
  };

  settings = {
    "addon@darkreader.org".settings = {
      syncSettings = true;
      syncSitesFixes = false;
      enableForPDF = true;
      detectDarkTheme = true;
      enableForProtectedPages = false;
      previewNewDesign = true;
      previewNewestDesign = false;
      enableContextMenus = false;
      displayedNews = ["google-docs-bugs"];
      changeBrowserTheme = false;
      schemeVersion = 2;
      presets = [];
      fetchNews = true;
      theme = {
        engine = "dynamicTheme";
        darkSchemeBackgroundColor = "#1e1e2e";
        darkSchemeTextColor = "#cdd6f4";
        lightSchemeBackgroundColor = "#dcdad7";
        lightSchemeTextColor = "#181a1b";
        scrollbarColor = "";
        selectionColor = "#585b70";
      };
      enabledByDefault = false;
      enabled = true;
    };

    "uBlock0@raymondhill.net".settings = {
      showIconBadge = false;
      cloudStorageEnabled = true;
      advancedUserEnabled = true;
      uiAccentCustom = true;
      uiAccent = "#cba7f6";
      selectedFilterLists = filterLists;
    };

    "sponsorBlocker@ajay.app".settings = {
      changeChapterColor = true;
      chapterCategoryAdded = true;
      autoSkipOnMusicVideosUpdate = true;
      dontShowNotice = true;
      permissions = {
        sponsor = true;
        selfpromo = true;
        exclusive_access = true;
        interaction = true;
        intro = true;
        outro = true;
        preview = true;
        hook = true;
        music_offtopic = true;
        filler = true;
        poi_highlight = true;
        chapter = false;
      };
    };

    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}".settings = {
      disableVoteSubmission = false;
      disableLogging = true;
      coloredThumbs = false;
      coloredBar = false;
      colorTheme = false;
      numberDisplayFormat = "compactShort";
      showTooltipPercentage = false;
      tooltipPercentageMode = "dash_like";
      numberDisplayReformatLikes = false;
      registrationConfirmed = true;
    };

    "firefox-extension@steamdb.info".settings = {
      enhancement-skip-agecheck = true;
      enhancement-no-linkfilter = true;
      enhancement-hide-mobile-app-button = false;
    };
  };
}
