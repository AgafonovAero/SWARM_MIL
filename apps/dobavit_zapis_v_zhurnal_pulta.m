function zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta(zhurnal_soobshchenii, tekst_soobshcheniya)
if nargin < 2 || strlength(string(tekst_soobshcheniya)) == 0
    error('%s', 'Для журнала пульта требуется непустой текст сообщения.');
end

if isempty(zhurnal_soobshchenii)
    zhurnal_soobshchenii = cell(0, 1);
end

if isstring(zhurnal_soobshchenii)
    zhurnal_soobshchenii = cellstr(zhurnal_soobshchenii);
elseif ischar(zhurnal_soobshchenii)
    zhurnal_soobshchenii = {zhurnal_soobshchenii};
elseif ~iscell(zhurnal_soobshchenii)
    error('%s', 'Журнал пульта должен быть строкой или списком строк.');
end

metka_vremeni = char(datetime('now', 'Format', 'HH:mm:ss'));
novaya_zapis = sprintf('[%s] %s', metka_vremeni, char(string(tekst_soobshcheniya)));
zhurnal_soobshchenii{end + 1, 1} = novaya_zapis;
end
