function rezultat = tochka_v_oblasti_poleta(tochka, oblast_poleta)
oblast_poleta = proverit_oblast_poleta(oblast_poleta, 'области полета');
tochka = proverit_tochku(tochka);

rezultat = tochka(1) >= oblast_poleta.xmin ...
    && tochka(1) <= oblast_poleta.xmax ...
    && tochka(2) >= oblast_poleta.ymin ...
    && tochka(2) <= oblast_poleta.ymax ...
    && tochka(3) >= oblast_poleta.zmin ...
    && tochka(3) <= oblast_poleta.zmax;
end

function tochka = proverit_tochku(tochka)
if ~isnumeric(tochka) || ~isvector(tochka) || numel(tochka) ~= 3
    error('%s', 'Точка должна быть числовым вектором из трех компонент.');
end

tochka = reshape(double(tochka), 1, 3);
if any(~isfinite(tochka))
    error('%s', 'Точка должна содержать только конечные числа.');
end
end
