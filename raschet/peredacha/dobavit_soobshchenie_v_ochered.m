function [ocheredi_bvs, soobshchenie, dobavleno] = dobavit_soobshchenie_v_ochered(ocheredi_bvs, id_bvs, soobshchenie, parametry_peredachi)
if nargin < 4
    error('%s', [ ...
        'Для добавления сообщения в очередь требуются очереди БВС, идентификатор БВС, ' ...
        'сообщение и параметры передачи.' ...
        ]);
end

parametry_peredachi = proverit_parametry_peredachi(parametry_peredachi);
id_bvs = char(string(id_bvs));
soobshchenie = proverit_soobshchenie(soobshchenie);

nomer_ocheredi = nayti_ochered(ocheredi_bvs, id_bvs);
tekushchaya_ochered = ocheredi_bvs(nomer_ocheredi).soobshcheniya;

if numel(tekushchaya_ochered) >= parametry_peredachi.maksimalnyi_razmer_ocheredi
    soobshchenie.poteryano = true;
    soobshchenie.prichina_poteri = 'perepolnenie_ocheredi';
    dobavleno = false;
    return
end

tekushchaya_ochered{end + 1} = soobshchenie; %#ok<AGROW>
ocheredi_bvs(nomer_ocheredi).soobshcheniya = tekushchaya_ochered;
dobavleno = true;
end

function nomer_ocheredi = nayti_ochered(ocheredi_bvs, id_bvs)
if ~isstruct(ocheredi_bvs) || isempty(ocheredi_bvs)
    error('%s', ...
        'Очереди БВС должны быть заданы непустым массивом структур.');
end

nomer_ocheredi = 0;
for indeks_ocheredi = 1:numel(ocheredi_bvs)
    if ~isfield(ocheredi_bvs(indeks_ocheredi), 'id_bvs') ...
            || ~isfield(ocheredi_bvs(indeks_ocheredi), 'soobshcheniya')
        error('%s', ...
            'Каждая очередь БВС должна содержать поля id_bvs и soobshcheniya.');
    end

    if strcmp(char(string(ocheredi_bvs(indeks_ocheredi).id_bvs)), id_bvs)
        nomer_ocheredi = indeks_ocheredi;
        break
    end
end

if nomer_ocheredi == 0
    error('%s', sprintf( ...
        'Не найдена очередь для БВС %s.', ...
        id_bvs));
end
end

function soobshchenie = proverit_soobshchenie(soobshchenie)
obyazatelnye_polya = {
    'id_soobshcheniya'
    'id_otpravitelya'
    'id_poluchatelya'
    'tekushchii_bvs'
    'vremya_sozdaniya'
    'razmer_bit'
    'tip_soobshcheniya'
    'marshrut'
    'chislo_peresylok'
    'dostavleno'
    'poteryano'
    'prichina_poteri'
    };

if ~isstruct(soobshchenie)
    error('%s', ...
        'Сообщение должно быть передано в виде структуры.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(soobshchenie, imya_polya)
        error('%s', sprintf( ...
            'В сообщении отсутствует обязательное поле %s.', ...
            imya_polya));
    end
end
end
