lib.addCommand('kedip', {
    help = 'Memuat ulang tekstur dunia jika mengalami texture loss / jalan bubur',
    params = {},
}, function(source)
    TriggerClientEvent('morph_kedip:client:fixTexture', source)
end)

