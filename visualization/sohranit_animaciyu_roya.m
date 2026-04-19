function put_k_failu = sohranit_animaciyu_roya(dannye_vizualizacii, put_k_failu, ogranichenie_chisla_kadrov)
if nargin < 2 || strlength(string(put_k_failu)) == 0
    error('%s', 'Для сохранения анимации требуется путь к выходному файлу.');
end

if nargin < 3 || isempty(ogranichenie_chisla_kadrov)
    ogranichenie_chisla_kadrov = 100;
end

if ~isscalar(ogranichenie_chisla_kadrov) || ogranichenie_chisla_kadrov < 1
    error('%s', ...
        'Ограничение числа кадров анимации должно быть положительным числом.');
end

put_k_failu = char(string(put_k_failu));
chislo_kadrov = min(numel(dannye_vizualizacii.kadry), ogranichenie_chisla_kadrov);

grafika = postroit_scenu_roya_3d(dannye_vizualizacii, false);
ochistka = onCleanup(@() close_bez_oshibki(grafika.figura));

try
    zapis_video = VideoWriter(put_k_failu, 'MPEG-4');
    open(zapis_video);
    ochistka_video = onCleanup(@() close_video_bez_oshibki(zapis_video));

    for nomer_kadra = 1:chislo_kadrov
        grafika = obnovit_kadr_roya(grafika, dannye_vizualizacii, nomer_kadra);
        kadr = getframe(grafika.figura);
        writeVideo(zapis_video, kadr);
    end

    clear ochistka_video
    close_video_bez_oshibki(zapis_video);
catch oshibka_video
    soobshchenie(sprintf( ...
        ['Не удалось сохранить анимацию роя в файл %s. ' ...
        'Причина: %s'], ...
        put_k_failu, oshibka_video.message), ...
        'preduprezhdenie');
    put_k_failu = '';
end

clear ochistka
close_bez_oshibki(grafika.figura);
end

function close_bez_oshibki(figura)
if ~isempty(figura) && isgraphics(figura)
    close(figura);
end
end

function close_video_bez_oshibki(zapis_video)
try
    close(zapis_video);
catch
end
end
