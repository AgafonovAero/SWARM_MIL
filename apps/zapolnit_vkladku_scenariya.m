function elementy = zapolnit_vkladku_scenariya(vkladka, sostoyanie_pulta)
if nargin < 2 || ~isstruct(sostoyanie_pulta)
    error('%s', ...
        'Для заполнения вкладки сценария требуется состояние пульта.');
end

maket = uigridlayout(vkladka, [4, 2]);
maket.RowHeight = {30, 120, 120, '1x'};
maket.ColumnWidth = {260, '1x'};
maket.Padding = [10, 10, 10, 10];

spisok_scenariev = uidropdown(maket);
spisok_scenariev.Layout.Row = 1;
spisok_scenariev.Layout.Column = 1;
spisok_scenariev.Items = poluchit_identifikatory_scenariev( ...
    sostoyanie_pulta.spisok_scenariev);
spisok_scenariev.Value = char(string(sostoyanie_pulta.tekushchii_scenarii.id_scenariya));

knopka_zagruzki = uibutton(maket, 'push');
knopka_zagruzki.Layout.Row = 1;
knopka_zagruzki.Layout.Column = 2;
knopka_zagruzki.Text = 'Загрузить сценарий';

tablica_sostava = uitable(maket);
tablica_sostava.Layout.Row = 2;
tablica_sostava.Layout.Column = [1, 2];
tablica_sostava.ColumnName = { ...
    'Идентификатор БВС'
    'Роль'
    'Запас энергии'
    };

tablica_tselei = uitable(maket);
tablica_tselei.Layout.Row = 3;
tablica_tselei.Layout.Column = [1, 2];
tablica_tselei.ColumnName = { ...
    'Идентификатор'
    'Тип'
    'Описание'
    };

oblast_opisaniya = uitextarea(maket);
oblast_opisaniya.Layout.Row = 4;
oblast_opisaniya.Layout.Column = 1;
oblast_opisaniya.Editable = 'off';

tablica_ogranichenii = uitable(maket);
tablica_ogranichenii.Layout.Row = 4;
tablica_ogranichenii.Layout.Column = 2;
tablica_ogranichenii.ColumnName = {'Признак', 'Значение'};

elementy = struct();
elementy.maket = maket;
elementy.spisok_scenariev = spisok_scenariev;
elementy.knopka_zagruzki = knopka_zagruzki;
elementy.tablica_sostava = tablica_sostava;
elementy.tablica_tselei = tablica_tselei;
elementy.oblast_opisaniya = oblast_opisaniya;
elementy.tablica_ogranichenii = tablica_ogranichenii;
end

function identifikatory = poluchit_identifikatory_scenariev(spisok_putei)
if isempty(spisok_putei)
    identifikatory = {''};
    return
end

identifikatory = cell(1, numel(spisok_putei));
for nomer_puti = 1:numel(spisok_putei)
    [~, imya_scenariya] = fileparts(spisok_putei{nomer_puti});
    identifikatory{nomer_puti} = imya_scenariya;
end
end
