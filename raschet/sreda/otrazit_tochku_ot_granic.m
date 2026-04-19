function [otrazhennaya_tochka, otrazhennaya_skorost] = otrazit_tochku_ot_granic(tochka, skorost, oblast_poleta)

oblast_poleta = proverit_oblast_poleta(oblast_poleta, 'области полета');
tochka = proverit_vektor_iz_treh_komponent(tochka, 'tochka');
skorost = proverit_vektor_iz_treh_komponent(skorost, 'skorost');

otrazhennaya_tochka = tochka;
otrazhennaya_skorost = skorost;
granitsy = [
    oblast_poleta.xmin, oblast_poleta.xmax
    oblast_poleta.ymin, oblast_poleta.ymax
    oblast_poleta.zmin, oblast_poleta.zmax
    ];

for nomer_osi = 1:3
    nizhnyaya_granica = granitsy(nomer_osi, 1);
    verhnyaya_granica = granitsy(nomer_osi, 2);

    while otrazhennaya_tochka(nomer_osi) < nizhnyaya_granica ...
            || otrazhennaya_tochka(nomer_osi) > verhnyaya_granica
        if otrazhennaya_tochka(nomer_osi) > verhnyaya_granica
            prevyshenie = otrazhennaya_tochka(nomer_osi) - verhnyaya_granica;
            otrazhennaya_tochka(nomer_osi) = verhnyaya_granica - prevyshenie;
            otrazhennaya_skorost(nomer_osi) = -otrazhennaya_skorost(nomer_osi);
        else
            prevyshenie = nizhnyaya_granica - otrazhennaya_tochka(nomer_osi);
            otrazhennaya_tochka(nomer_osi) = nizhnyaya_granica + prevyshenie;
            otrazhennaya_skorost(nomer_osi) = -otrazhennaya_skorost(nomer_osi);
        end
    end
end
end

function vektor = proverit_vektor_iz_treh_komponent(vektor, imya_vektora)
if ~isnumeric(vektor) || ~isvector(vektor) || numel(vektor) ~= 3
    error('%s', sprintf( ...
        'Параметр %s должен быть числовым вектором из трех компонент.', ...
        imya_vektora));
end

vektor = reshape(double(vektor), 1, 3);
if any(~isfinite(vektor))
    error('%s', sprintf( ...
        'Параметр %s должен содержать только конечные числа.', ...
        imya_vektora));
end
end
