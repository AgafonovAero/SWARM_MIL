function [put_k_modeli, imya_modeli] = sozdat_model_stenda_roya(koren_proekta, otkryt_model, perezapisat_model)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для создания Simulink-модели требуется корень проекта.');
end

if nargin < 2 || isempty(otkryt_model)
    otkryt_model = false;
end

if nargin < 3 || isempty(perezapisat_model)
    perezapisat_model = true;
end

proverit_dostupnost_simulink();

imya_modeli = 'SWARM_MIL_STEND';
papka_generated = fullfile(koren_proekta, 'bloki', 'generated');
put_k_modeli = fullfile(papka_generated, [imya_modeli '.slx']);

if ~isfolder(papka_generated)
    mkdir(papka_generated);
end

if isfile(put_k_modeli) && ~perezapisat_model
    load_system(put_k_modeli);
    if otkryt_model
        open_system(put_k_modeli);
    end
    return
end

zakryt_model_esli_otkryt(imya_modeli);

if isfile(put_k_modeli)
    delete(put_k_modeli);
end

new_system(imya_modeli);

try
    postroit_verhniy_uroven(imya_modeli);
    dobavit_annotacii(imya_modeli);
    sohranit_model(imya_modeli, put_k_modeli, otkryt_model);
catch oshibka_postroeniya
    zakryt_model_esli_otkryt(imya_modeli);
    error('%s', sprintf( ...
        'Не удалось создать Simulink-модель стенда: %s', ...
        oshibka_postroeniya.message));
end
end

function proverit_dostupnost_simulink()
if isempty(ver('Simulink'))
    error('%s', ...
        'Simulink недоступен. Построение обзорной модели стенда невозможно.');
end

if ~license('test', 'Simulink')
    error('%s', ...
        'Лицензия Simulink недоступна для построения обзорной модели стенда.');
end
end

function postroit_verhniy_uroven(imya_modeli)
nazvaniya = { ...
    'Сценарий'
    'Кинематика'
    'Связность'
    'Звенья'
    'Передача'
    'Визуализация'
    'Оценка'
    'Параметры'
    'Журнал'
    };

pozicii = { ...
    [40, 150, 150, 220]
    [200, 150, 310, 220]
    [360, 150, 470, 220]
    [520, 150, 630, 220]
    [680, 150, 790, 220]
    [840, 150, 950, 220]
    [1000, 150, 1110, 220]
    [360, 300, 500, 370]
    [680, 300, 820, 370]
    };

for nomer_bloka = 1:numel(nazvaniya)
    put_k_bloku = sprintf('%s/%s', imya_modeli, nazvaniya{nomer_bloka});
    add_block( ...
        'simulink/Ports & Subsystems/Subsystem', ...
        put_k_bloku, ...
        'Position', pozicii{nomer_bloka});
end

dobavit_soedineniya(imya_modeli);
nastroit_podsistemu_parametrov(imya_modeli);
nastroit_podsistemu_zhurnala(imya_modeli);
end

function dobavit_soedineniya(imya_modeli)
pary_soedineniy = { ...
    'Сценарий/1', 'Кинематика/1'
    'Кинематика/1', 'Связность/1'
    'Связность/1', 'Звенья/1'
    'Звенья/1', 'Передача/1'
    'Передача/1', 'Визуализация/1'
    'Визуализация/1', 'Оценка/1'
    };

for nomer_soedineniya = 1:size(pary_soedineniy, 1)
    add_line( ...
        imya_modeli, ...
        pary_soedineniy{nomer_soedineniya, 1}, ...
        pary_soedineniy{nomer_soedineniya, 2}, ...
        'autorouting', 'on');
end
end

function nastroit_podsistemu_parametrov(imya_modeli)
put_k_podsisteme = sprintf('%s/%s', imya_modeli, 'Параметры');
delete_lines_vnutri_podsistemy(put_k_podsisteme);
udalit_standartnye_porty(put_k_podsisteme);

add_block( ...
    'simulink/Sources/Constant', ...
    sprintf('%s/%s', put_k_podsisteme, 'Параметры связи'), ...
    'Position', [40, 40, 160, 70], ...
    'Value', 'parametry_svyazi_po_umolchaniyu()');
add_block( ...
    'simulink/Sources/Constant', ...
    sprintf('%s/%s', put_k_podsisteme, 'Параметры звеньев'), ...
    'Position', [40, 95, 160, 125], ...
    'Value', 'parametry_zvenev_po_umolchaniyu()');
add_block( ...
    'simulink/Sources/Constant', ...
    sprintf('%s/%s', put_k_podsisteme, 'Параметры передачи'), ...
    'Position', [40, 150, 160, 180], ...
    'Value', 'parametry_peredachi_po_umolchaniyu()');
end

function nastroit_podsistemu_zhurnala(imya_modeli)
put_k_podsisteme = sprintf('%s/%s', imya_modeli, 'Журнал');
udalit_standartnye_porty(put_k_podsisteme);

annotation_zhurnala = Simulink.Annotation( ...
    put_k_podsisteme, ...
    ['Подсистема журнала показывает место для сообщений о ходе ' ...
     'расчетного опыта и итоговых примечаний.']);
annotation_zhurnala.Position = [25, 35, 220, 65];
end

function delete_lines_vnutri_podsistemy(put_k_podsisteme)
linii = find_system( ...
    put_k_podsisteme, ...
    'FindAll', 'on', ...
    'SearchDepth', 1, ...
    'Type', 'line');
for nomer_linii = 1:numel(linii)
    delete_line(linii(nomer_linii));
end
end

function udalit_standartnye_porty(put_k_podsisteme)
blok_in = find_system( ...
    put_k_podsisteme, ...
    'SearchDepth', 1, ...
    'BlockType', 'Inport');
blok_out = find_system( ...
    put_k_podsisteme, ...
    'SearchDepth', 1, ...
    'BlockType', 'Outport');

udalit_bloki(blok_in);
udalit_bloki(blok_out);
end

function udalit_bloki(spisok_blokov)
for nomer_bloka = 1:numel(spisok_blokov)
    if contains(spisok_blokov{nomer_bloka}, '/')
        delete_block(spisok_blokov{nomer_bloka});
    end
end
end

function dobavit_annotacii(imya_modeli)
annotaciya_glavnaya = Simulink.Annotation( ...
    imya_modeli, ...
    ['Расчет выполняется существующим MATLAB-ядром проекта. ' ...
     'Simulink-модель служит обзорной оболочкой стенда.']);
annotaciya_glavnaya.Position = [35, 35, 460, 55];

annotaciya_parametrov = Simulink.Annotation( ...
    imya_modeli, ...
    ['Подсистема параметров хранит настройки связи, звеньев и передачи ' ...
     'сообщений для запуска расчетного опыта.']);
annotaciya_parametrov.Position = [360, 395, 360, 55];
end

function sohranit_model(imya_modeli, put_k_modeli, otkryt_model)
save_system(imya_modeli, put_k_modeli);

if otkryt_model
    open_system(put_k_modeli);
else
    close_system(imya_modeli, 0);
end
end

function zakryt_model_esli_otkryt(imya_modeli)
if bdIsLoaded(imya_modeli)
    close_system(imya_modeli, 0);
end
end
