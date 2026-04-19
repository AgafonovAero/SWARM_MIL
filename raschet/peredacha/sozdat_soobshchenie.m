function soobshchenie = sozdat_soobshchenie(id_soobshcheniya, id_otpravitelya, id_poluchatelya, vremya_sozdaniya, razmer_soobshcheniya_bit, tip_soobshcheniya)
id_soobshcheniya = proverit_nepustuyu_stroku( ...
    id_soobshcheniya, ...
    'id_soobshcheniya');
id_otpravitelya = proverit_nepustuyu_stroku( ...
    id_otpravitelya, ...
    'id_otpravitelya');
id_poluchatelya = proverit_nepustuyu_stroku( ...
    id_poluchatelya, ...
    'id_poluchatelya');
tip_soobshcheniya = proverit_tip_soobshcheniya(tip_soobshcheniya);

if strcmp(id_otpravitelya, id_poluchatelya)
    error('%s', ...
        'Отправитель и получатель сообщения не должны совпадать.');
end

if ~isnumeric(vremya_sozdaniya) || ~isscalar(vremya_sozdaniya) ...
        || ~isfinite(vremya_sozdaniya)
    error('%s', ...
        'Время создания сообщения должно быть конечным числом.');
end

if ~isnumeric(razmer_soobshcheniya_bit) || ~isscalar(razmer_soobshcheniya_bit) ...
        || ~isfinite(razmer_soobshcheniya_bit) || razmer_soobshcheniya_bit <= 0
    error('%s', ...
        'Размер сообщения должен быть положительным конечным числом.');
end

soobshchenie = struct();
soobshchenie.id_soobshcheniya = id_soobshcheniya;
soobshchenie.id_otpravitelya = id_otpravitelya;
soobshchenie.id_poluchatelya = id_poluchatelya;
soobshchenie.tekushchii_bvs = id_otpravitelya;
soobshchenie.vremya_sozdaniya = double(vremya_sozdaniya);
soobshchenie.razmer_bit = double(razmer_soobshcheniya_bit);
soobshchenie.tip_soobshcheniya = tip_soobshcheniya;
soobshchenie.marshrut = {id_otpravitelya};
soobshchenie.chislo_peresylok = 0;
soobshchenie.dostavleno = false;
soobshchenie.poteryano = false;
soobshchenie.prichina_poteri = '';
soobshchenie.vremya_dostavki = NaN;
soobshchenie.zaderzhka_dostavki_s = NaN;
end

function znachenie = proverit_nepustuyu_stroku(znachenie, imya_polya)
if ~(ischar(znachenie) || isstring(znachenie))
    error('%s', sprintf( ...
        'Поле %s должно быть строкой.', ...
        imya_polya));
end

znachenie = char(string(znachenie));
if strlength(string(znachenie)) == 0
    error('%s', sprintf( ...
        'Поле %s не должно быть пустым.', ...
        imya_polya));
end
end

function tip_soobshcheniya = proverit_tip_soobshcheniya(tip_soobshcheniya)
tip_soobshcheniya = proverit_nepustuyu_stroku( ...
    tip_soobshcheniya, ...
    'tip_soobshcheniya');

dopustimye_tipy = {
    'sluzhebnoe'
    'issledovatelskoe'
    };

if ~any(strcmp(dopustimye_tipy, tip_soobshcheniya))
    error('%s', sprintf( ...
        'Тип сообщения %s не допускается на этапе 6.', ...
        tip_soobshcheniya));
end
end
