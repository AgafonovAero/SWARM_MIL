function put_k_failu = sohranit_kadr_roya(dannye_vizualizacii, koren_proekta, nomer_kadra)
if nargin < 2
    error('%s', ...
        'Для сохранения кадра требуются данные визуализации и корень проекта.');
end

if nargin < 3 || isempty(nomer_kadra)
    nomer_kadra = 1;
end

if nomer_kadra < 1 || nomer_kadra > numel(dannye_vizualizacii.kadry)
    error('%s', sprintf( ...
        'Номер кадра %d не входит в диапазон подготовленных кадров.', ...
        nomer_kadra));
end

papka_rezultatov = fullfile(koren_proekta, 'opyty', 'rezultaty');
if ~isfolder(papka_rezultatov)
    error('%s', sprintf( ...
        'Не найдена папка результатов для сохранения кадра: %s', ...
        papka_rezultatov));
end

bezopasnyi_id = sdelat_bezopasnoe_imya(dannye_vizualizacii.id_scenariya);
imya_faila = sprintf('%s_kadr_%03d.png', bezopasnyi_id, nomer_kadra);
put_k_failu = fullfile(papka_rezultatov, imya_faila);

grafika = postroit_scenu_roya_3d(dannye_vizualizacii, false);
ochistka = onCleanup(@() close_bez_oshibki(grafika.figura));
grafika = obnovit_kadr_roya(grafika, dannye_vizualizacii, nomer_kadra);

try
    exportgraphics(grafika.osi, put_k_failu, 'Resolution', 150);
catch
    saveas(grafika.figura, put_k_failu);
end

clear ochistka
close_bez_oshibki(grafika.figura);
end

function imya = sdelat_bezopasnoe_imya(znachenie)
imya = regexprep(char(string(znachenie)), '[^A-Za-zА-Яа-я0-9_\\-]', '_');
end

function close_bez_oshibki(figura)
if ~isempty(figura) && isgraphics(figura)
    close(figura);
end
end
