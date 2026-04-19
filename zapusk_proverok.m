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
    soobshchenie('Проверки этапа 1 завершены успешно');
catch oshibka_proverki
    soobshchenie(sprintf('Проверки проекта завершены с ошибкой: %s', oshibka_proverki.message), 'oshibka');
    rethrow(oshibka_proverki);
end
end

function proverit_zapis_v_rezultaty(koren_proekta)
papka_rezultatov = fullfile(koren_proekta, 'opyty', 'rezultaty');
imya_vremennogo_faila = ['proverka_zapisi_' char(datetime('now', 'Format', 'yyyyMMdd_HHmmss')) '.txt'];
put_k_failu = fullfile(papka_rezultatov, imya_vremennogo_faila);

[identifikator, soobshchenie_oshibki] = fopen(put_k_failu, 'w');
if identifikator == -1
    error('Нет возможности записи в папку: %s. %s', papka_rezultatov, soobshchenie_oshibki);
end

fprintf(identifikator, 'Проверка записи этапа 0.%s', newline);
status_zakrytiya = fclose(identifikator);
if status_zakrytiya ~= 0
    error('Не удалось закрыть временный файл проверки записи: %s', put_k_failu);
end

if ~isfile(put_k_failu)
    error('Не создан временный файл проверки записи: %s', put_k_failu);
end

try
    delete(put_k_failu);
catch oshibka_udaleniya
    error('Не удалось удалить временный файл проверки записи: %s. %s', ...
        put_k_failu, oshibka_udaleniya.message);
end

if isfile(put_k_failu)
    error('Не удалось удалить временный файл проверки записи: %s', put_k_failu);
end

soobshchenie('Папка результатов доступна для записи.');
end

function vyvesti_svedeniya_o_sredah
svedeniya_raschetnoi_sredy = ver('MATLAB');
if isempty(svedeniya_raschetnoi_sredy)
    error('Не удалось получить сведения о расчетной среде.');
end

svedeniya_blochnoi_sredy = ver('Simulink');
if isempty(svedeniya_blochnoi_sredy)
    error('Не удалось получить сведения о блочной среде.');
end

soobshchenie(sprintf('Расчетная среда: выпуск %s, версия %s.', ...
    svedeniya_raschetnoi_sredy.Release, svedeniya_raschetnoi_sredy.Version));
soobshchenie(sprintf('Блочная среда: выпуск %s, версия %s.', ...
    svedeniya_blochnoi_sredy.Release, svedeniya_blochnoi_sredy.Version));
end
