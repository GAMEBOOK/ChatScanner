-- ChatScanner PRO Localization
local addonName, addon = ...

-- Create localization table
local L = {}
addon.L = L

-- Get client locale
local locale = GetLocale()

-- Default English strings
local enUS = {
    -- General
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Enable",
    ["Disable"] = "Disable",
    ["Enabled"] = "Enabled",
    ["Disabled"] = "Disabled",
    ["Delete"] = "Delete",
    ["Test"] = "Test",
    ["Save"] = "Save",
    ["Cancel"] = "Cancel",
    ["Close"] = "Close",
    ["Refresh"] = "Refresh",
    
    -- Tabs
    ["Settings"] = "Settings",
    ["Keyword Filters"] = "Keyword Filters",
    ["Channels"] = "Channels",
    ["Notifications"] = "Notifications",
    ["Auto Messages"] = "Auto Messages",
    ["Match History"] = "Match History",
    ["Blacklist"] = "Blacklist",
    ["Quick Replies"] = "Quick Replies",
    ["Help & Guide"] = "Help & Guide",
    
    -- Settings
    ["Enable or disable the addon"] = "Enable or disable the addon",
    ["Show Minimap Button"] = "Show Minimap Button",
    ["Hide Menu Button"] = "Hide Menu Button",
    ["Ignore Own Messages"] = "Ignore Own Messages",
    ["Anti-Spam Filter"] = "Anti-Spam Filter",
    ["Notification Duration"] = "Notification Duration",
    ["Max Notifications"] = "Max Notifications",
    ["Pause in Combat"] = "Pause in Combat",
    
    -- Filters
    ["Add New Filter"] = "+ Add New Filter",
    ["Filter Name"] = "Filter Name",
    ["Keywords"] = "Keywords",
    ["Category"] = "Category",
    ["Color"] = "Color",
    ["Play Sound"] = "Play Sound",
    ["Add Standard"] = "+ Standard",
    ["Add Required"] = "+ Required",
    ["Add Group"] = "+ Group",
    
    -- Channels
    ["Say"] = "Say",
    ["Yell"] = "Yell",
    ["Guild"] = "Guild",
    ["Party"] = "Party",
    ["Raid"] = "Raid",
    ["Whisper"] = "Whisper",
    ["Enable All Channels"] = "Enable All Channels",
    
    -- Auto Messages
    ["Add New Message"] = "+ Add New Message",
    ["Message Text"] = "Message Text",
    ["Channel"] = "Channel",
    ["Interval"] = "Interval",
    ["Start Auto Messages"] = "Start Auto Messages",
    ["Stop Auto Messages"] = "Stop Auto Messages",
    
    -- History
    ["Enable History"] = "Enable History",
    ["Max Entries"] = "Max Entries",
    ["Clear History"] = "Clear History",
    ["Fix Corrupted Entries"] = "Fix Corrupted Entries",
    ["Search by Player"] = "Search by Player",
    ["Search by Filter"] = "Search by Filter",
    ["Search by Channel"] = "Search by Channel",
    
    -- Blacklist
    ["Clear All Blacklist"] = "Clear All Blacklist",
    ["No blacklisted players"] = "No blacklisted players",
    ["Forever"] = "Forever",
    ["Expired"] = "Expired",
    
    -- Templates
    ["Add New Template"] = "+ Add New Template",
    ["Template Name"] = "Template Name",
    ["Response Text"] = "Response Text",
    
    -- Messages
    ["added to blacklist"] = "added to blacklist",
    ["for"] = "for",
    ["History cleared"] = "History cleared",
    ["Filter created"] = "New filter created. Configure it and enable it when ready!",
    ["Message created"] = "New message created. Configure it and enable it when ready!",
    ["Template created"] = "New template created. Configure it and enable it when ready!",
    ["Already unconfigured"] = "You already have an unconfigured %s. Please configure it first!",
    ["Closed notifications"] = "Closed %d notification(s) from %s",
}

-- French translations
local frFR = {
    -- General
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Activer",
    ["Disable"] = "Désactiver",
    ["Enabled"] = "Activé",
    ["Disabled"] = "Désactivé",
    ["Delete"] = "Supprimer",
    ["Test"] = "Tester",
    ["Save"] = "Sauvegarder",
    ["Cancel"] = "Annuler",
    ["Close"] = "Fermer",
    ["Refresh"] = "Actualiser",
    
    -- Tabs
    ["Settings"] = "Paramètres",
    ["Keyword Filters"] = "Filtres de Mots-clés",
    ["Channels"] = "Canaux",
    ["Notifications"] = "Notifications",
    ["Auto Messages"] = "Messages Auto",
    ["Match History"] = "Historique",
    ["Blacklist"] = "Liste Noire",
    ["Quick Replies"] = "Réponses Rapides",
    ["Help & Guide"] = "Aide & Guide",
    
    -- Settings
    ["Enable or disable the addon"] = "Activer ou désactiver l'addon",
    ["Show Minimap Button"] = "Afficher le Bouton Minimap",
    ["Hide Menu Button"] = "Cacher le Bouton Menu",
    ["Ignore Own Messages"] = "Ignorer Mes Messages",
    ["Anti-Spam Filter"] = "Filtre Anti-Spam",
    ["Notification Duration"] = "Durée des Notifications",
    ["Max Notifications"] = "Notifications Max",
    ["Pause in Combat"] = "Pause en Combat",
    
    -- Filters
    ["Add New Filter"] = "+ Nouveau Filtre",
    ["Filter Name"] = "Nom du Filtre",
    ["Keywords"] = "Mots-clés",
    ["Category"] = "Catégorie",
    ["Color"] = "Couleur",
    ["Play Sound"] = "Jouer un Son",
    ["Add Standard"] = "+ Standard",
    ["Add Required"] = "+ Requis",
    ["Add Group"] = "+ Groupe",
    
    -- Channels
    ["Say"] = "Dire",
    ["Yell"] = "Crier",
    ["Guild"] = "Guilde",
    ["Party"] = "Groupe",
    ["Raid"] = "Raid",
    ["Whisper"] = "Chuchoter",
    ["Enable All Channels"] = "Activer Tous les Canaux",
    
    -- Auto Messages
    ["Add New Message"] = "+ Nouveau Message",
    ["Message Text"] = "Texte du Message",
    ["Channel"] = "Canal",
    ["Interval"] = "Intervalle",
    ["Start Auto Messages"] = "Démarrer Messages Auto",
    ["Stop Auto Messages"] = "Arrêter Messages Auto",
    
    -- History
    ["Enable History"] = "Activer l'Historique",
    ["Max Entries"] = "Entrées Max",
    ["Clear History"] = "Effacer l'Historique",
    ["Fix Corrupted Entries"] = "Réparer Entrées Corrompues",
    ["Search by Player"] = "Rechercher par Joueur",
    ["Search by Filter"] = "Rechercher par Filtre",
    ["Search by Channel"] = "Rechercher par Canal",
    
    -- Blacklist
    ["Clear All Blacklist"] = "Effacer Toute la Liste Noire",
    ["No blacklisted players"] = "Aucun joueur dans la liste noire",
    ["Forever"] = "Pour Toujours",
    ["Expired"] = "Expiré",
    
    -- Templates
    ["Add New Template"] = "+ Nouveau Modèle",
    ["Template Name"] = "Nom du Modèle",
    ["Response Text"] = "Texte de Réponse",
    
    -- Messages
    ["added to blacklist"] = "ajouté à la liste noire",
    ["for"] = "pour",
    ["History cleared"] = "Historique effacé",
    ["Filter created"] = "Nouveau filtre créé. Configurez-le et activez-le quand vous êtes prêt !",
    ["Message created"] = "Nouveau message créé. Configurez-le et activez-le quand vous êtes prêt !",
    ["Template created"] = "Nouveau modèle créé. Configurez-le et activez-le quand vous êtes prêt !",
    ["Already unconfigured"] = "Vous avez déjà un(e) %s non configuré(e). Veuillez le/la configurer d'abord !",
    ["Closed notifications"] = "%d notification(s) fermée(s) de %s",
}

-- German translations
local deDE = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Aktivieren",
    ["Disable"] = "Deaktivieren",
    ["Enabled"] = "Aktiviert",
    ["Disabled"] = "Deaktiviert",
    ["Delete"] = "Löschen",
    ["Test"] = "Testen",
    ["Settings"] = "Einstellungen",
    ["Keyword Filters"] = "Stichwortfilter",
    ["Channels"] = "Kanäle",
    ["Notifications"] = "Benachrichtigungen",
    ["Auto Messages"] = "Auto-Nachrichten",
    ["Match History"] = "Verlauf",
    ["Blacklist"] = "Sperrliste",
    ["Quick Replies"] = "Schnellantworten",
    ["Help & Guide"] = "Hilfe & Anleitung",
    ["Add New Filter"] = "+ Neuer Filter",
    ["Add New Message"] = "+ Neue Nachricht",
    ["Add New Template"] = "+ Neue Vorlage",
    ["Enable All Channels"] = "Alle Kanäle aktivieren",
    ["Clear History"] = "Verlauf löschen",
    ["Forever"] = "Für immer",
}

-- Spanish translations
local esES = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Activar",
    ["Disable"] = "Desactivar",
    ["Enabled"] = "Activado",
    ["Disabled"] = "Desactivado",
    ["Delete"] = "Eliminar",
    ["Test"] = "Probar",
    ["Settings"] = "Configuración",
    ["Keyword Filters"] = "Filtros de Palabras Clave",
    ["Channels"] = "Canales",
    ["Notifications"] = "Notificaciones",
    ["Auto Messages"] = "Mensajes Automáticos",
    ["Match History"] = "Historial",
    ["Blacklist"] = "Lista Negra",
    ["Quick Replies"] = "Respuestas Rápidas",
    ["Help & Guide"] = "Ayuda y Guía",
    ["Add New Filter"] = "+ Nuevo Filtro",
    ["Add New Message"] = "+ Nuevo Mensaje",
    ["Add New Template"] = "+ Nueva Plantilla",
    ["Enable All Channels"] = "Activar Todos los Canales",
    ["Clear History"] = "Borrar Historial",
    ["Forever"] = "Para Siempre",
}

-- Portuguese translations
local ptBR = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Ativar",
    ["Disable"] = "Desativar",
    ["Enabled"] = "Ativado",
    ["Disabled"] = "Desativado",
    ["Delete"] = "Excluir",
    ["Test"] = "Testar",
    ["Settings"] = "Configurações",
    ["Keyword Filters"] = "Filtros de Palavras-chave",
    ["Channels"] = "Canais",
    ["Notifications"] = "Notificações",
    ["Auto Messages"] = "Mensagens Automáticas",
    ["Match History"] = "Histórico",
    ["Blacklist"] = "Lista Negra",
    ["Quick Replies"] = "Respostas Rápidas",
    ["Help & Guide"] = "Ajuda e Guia",
    ["Add New Filter"] = "+ Novo Filtro",
    ["Add New Message"] = "+ Nova Mensagem",
    ["Add New Template"] = "+ Novo Modelo",
    ["Enable All Channels"] = "Ativar Todos os Canais",
    ["Clear History"] = "Limpar Histórico",
    ["Forever"] = "Para Sempre",
}

-- Russian translations
local ruRU = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Включить",
    ["Disable"] = "Отключить",
    ["Enabled"] = "Включено",
    ["Disabled"] = "Отключено",
    ["Delete"] = "Удалить",
    ["Test"] = "Тест",
    ["Settings"] = "Настройки",
    ["Keyword Filters"] = "Фильтры Ключевых Слов",
    ["Channels"] = "Каналы",
    ["Notifications"] = "Уведомления",
    ["Auto Messages"] = "Авто-Сообщения",
    ["Match History"] = "История",
    ["Blacklist"] = "Черный Список",
    ["Quick Replies"] = "Быстрые Ответы",
    ["Help & Guide"] = "Помощь и Руководство",
    ["Add New Filter"] = "+ Новый Фильтр",
    ["Add New Message"] = "+ Новое Сообщение",
    ["Add New Template"] = "+ Новый Шаблон",
    ["Enable All Channels"] = "Включить Все Каналы",
    ["Clear History"] = "Очистить Историю",
    ["Forever"] = "Навсегда",
}

-- Italian translations
local itIT = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "Attiva",
    ["Disable"] = "Disattiva",
    ["Enabled"] = "Attivato",
    ["Disabled"] = "Disattivato",
    ["Delete"] = "Elimina",
    ["Test"] = "Test",
    ["Settings"] = "Impostazioni",
    ["Keyword Filters"] = "Filtri Parole Chiave",
    ["Channels"] = "Canali",
    ["Notifications"] = "Notifiche",
    ["Auto Messages"] = "Messaggi Automatici",
    ["Match History"] = "Cronologia",
    ["Blacklist"] = "Lista Nera",
    ["Quick Replies"] = "Risposte Rapide",
    ["Help & Guide"] = "Aiuto e Guida",
    ["Add New Filter"] = "+ Nuovo Filtro",
    ["Add New Message"] = "+ Nuovo Messaggio",
    ["Add New Template"] = "+ Nuovo Modello",
    ["Enable All Channels"] = "Attiva Tutti i Canali",
    ["Clear History"] = "Cancella Cronologia",
    ["Forever"] = "Per Sempre",
}

-- Korean translations
local koKR = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "활성화",
    ["Disable"] = "비활성화",
    ["Enabled"] = "활성화됨",
    ["Disabled"] = "비활성화됨",
    ["Delete"] = "삭제",
    ["Test"] = "테스트",
    ["Settings"] = "설정",
    ["Keyword Filters"] = "키워드 필터",
    ["Channels"] = "채널",
    ["Notifications"] = "알림",
    ["Auto Messages"] = "자동 메시지",
    ["Match History"] = "기록",
    ["Blacklist"] = "차단 목록",
    ["Quick Replies"] = "빠른 답장",
    ["Help & Guide"] = "도움말 및 가이드",
    ["Add New Filter"] = "+ 새 필터",
    ["Add New Message"] = "+ 새 메시지",
    ["Add New Template"] = "+ 새 템플릿",
    ["Enable All Channels"] = "모든 채널 활성화",
    ["Clear History"] = "기록 지우기",
    ["Forever"] = "영구",
}

-- Chinese Simplified translations
local zhCN = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "启用",
    ["Disable"] = "禁用",
    ["Enabled"] = "已启用",
    ["Disabled"] = "已禁用",
    ["Delete"] = "删除",
    ["Test"] = "测试",
    ["Settings"] = "设置",
    ["Keyword Filters"] = "关键词过滤器",
    ["Channels"] = "频道",
    ["Notifications"] = "通知",
    ["Auto Messages"] = "自动消息",
    ["Match History"] = "历史记录",
    ["Blacklist"] = "黑名单",
    ["Quick Replies"] = "快速回复",
    ["Help & Guide"] = "帮助和指南",
    ["Add New Filter"] = "+ 新建过滤器",
    ["Add New Message"] = "+ 新建消息",
    ["Add New Template"] = "+ 新建模板",
    ["Enable All Channels"] = "启用所有频道",
    ["Clear History"] = "清除历史",
    ["Forever"] = "永久",
}

-- Chinese Traditional translations
local zhTW = {
    ["ChatScanner PRO"] = "ChatScanner PRO",
    ["Enable"] = "啟用",
    ["Disable"] = "停用",
    ["Enabled"] = "已啟用",
    ["Disabled"] = "已停用",
    ["Delete"] = "刪除",
    ["Test"] = "測試",
    ["Settings"] = "設定",
    ["Keyword Filters"] = "關鍵字過濾器",
    ["Channels"] = "頻道",
    ["Notifications"] = "通知",
    ["Auto Messages"] = "自動訊息",
    ["Match History"] = "歷史記錄",
    ["Blacklist"] = "黑名單",
    ["Quick Replies"] = "快速回覆",
    ["Help & Guide"] = "說明與指南",
    ["Add New Filter"] = "+ 新增過濾器",
    ["Add New Message"] = "+ 新增訊息",
    ["Add New Template"] = "+ 新增範本",
    ["Enable All Channels"] = "啟用所有頻道",
    ["Clear History"] = "清除歷史",
    ["Forever"] = "永久",
}

-- Set locale
local translations = {
    enUS = enUS,
    enGB = enUS, -- British English uses US English
    frFR = frFR,
    deDE = deDE,
    esES = esES,
    esMX = esES, -- Mexican Spanish uses Spain Spanish
    ptBR = ptBR,
    ruRU = ruRU,
    itIT = itIT,
    koKR = koKR,
    zhCN = zhCN,
    zhTW = zhTW,
}

-- Fallback to English if locale not found
local currentLocale = translations[locale] or enUS

-- Create metatable for automatic fallback to English
setmetatable(L, {
    __index = function(t, key)
        return currentLocale[key] or enUS[key] or key
    end
})
