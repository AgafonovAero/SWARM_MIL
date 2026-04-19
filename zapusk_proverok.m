function zapusk_proverok
koren_proekta = fileparts(mfilename('fullpath'));

addpath(fullfile(koren_proekta, 'raschet', 'otsenka'));
addpath(fullfile(koren_proekta, 'proverki', 'edinichnye'));

try
    soobshchenie('Начат запуск проверок этапов 0 и 1.');

    proverka_struktury_proekta(koren_proekta);
    proverit_zapis_v_rezultaty(koren_proekta);
    vyvesti_svedeniya_o_sredah();
    soobshchenie('Проверки этапа 0 завершены успешно');

    proverka_dokumentov_etapa_1(koren_proekta);
    proverka_skrytyh_znakov(koren_proekta);
    proverka_razmetki_markdown(koren_proekta);
    soobshchenie('Проверки этапа 1 завершены успешно');
catch oshibka_proverki
    soobshchenie(...
        sprintf('Проверки проекта завершены с ошибкой: %s', oshibka_proverki.message), ...
        'oshibka');
    rethrow(oshibka_proverki);
end
end

function proverit_zapis_v_rezultaty(koren_proekta)
papka_rezultatov = fullfile(koren_proekta, 'opyty', 'rezultaty');
metka_vremeni = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
imya_vremennogo_faila = ['proverka_zapisi_' metka_vremeni '.txt'];
put_k_failu = fullfile(papka_rezultatov, imya_vremennogo_faila);

[identifikator, tekst_oshibki] = fopen(put_k_failu, 'w');
if identifikator == -1
    soobshchenie_ob_oshibke = sprintf( ...
        'Нет возможности записи в папку результатов %s. Причина: %s', ...
        papka_rezultatov, tekst_oshibki);
    error('%s', soobshchenie_ob_oshibke);
end

fprintf(identifikator, 'Проверка записи этапа 0.%s', newline);

status_zakrytiya = fclose(identifikator);
if status_zakrytiya ~= 0
    error('%s', sprintf( ...
        'Не удалось закрыть временный файл проверки записи: %s', ...
        put_k_failu));
end

if ~isfile(put_k_failu)
    error('%s', sprintf( ...
        'Не создан временный файл проверки записи: %s', ...
        put_k_failu));
end

try
    delete(put_k_failu);
catch oshibka_udaleniya
    soobshchenie_ob_oshibke = sprintf( ...
        ['Не удалось удалить временный файл проверки записи: %s.%s' ...
        'Причина: %s'], ...
        put_k_failu, newline, oshibka_udaleniya.message);
    error('%s', soobshchenie_ob_oshibke);
end

if isfile(put_k_failu)
    error('%s', sprintf( ...
        'Не удалось удалить временный файл проверки записи: %s', ...
        put_k_failu));
end

soobshchenie('Папка результатов доступна для записи.');
end

function vyvesti_svedeniya_o_sredah
svedeniya_o_matlab = ver('MATLAB');
if isempty(svedeniya_o_matlab)
    error('%s', 'Не удалось получить сведения о MATLAB.');
end

svedeniya_o_simulink = ver('Simulink');
if isempty(svedeniya_o_simulink)
    error('%s', 'Не удалось получить сведения о Simulink.');
end

soobshchenie(sprintf( ...
    'Расчетная среда MATLAB: выпуск %s, версия %s.', ...
    svedeniya_o_matlab.Release, svedeniya_o_matlab.Version));
soobshchenie(sprintf( ...
    'Блочная среда Simulink: выпуск %s, версия %s.', ...
    svedeniya_o_simulink.Release, svedeniya_o_simulink.Version));
end
