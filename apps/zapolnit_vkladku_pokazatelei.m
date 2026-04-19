function elementy = zapolnit_vkladku_pokazatelei(vkladka)
maket = uigridlayout(vkladka, [2, 1]);
maket.RowHeight = {160, '1x'};
maket.ColumnWidth = {'1x'};
maket.Padding = [10, 10, 10, 10];

panel_tablicy = uigridlayout(maket, [2, 2]);
panel_tablicy.Layout.Row = 1;
panel_tablicy.Layout.Column = 1;
panel_tablicy.RowHeight = {32, '1x'};
panel_tablicy.ColumnWidth = {'1x', 180};

tablica_pokazatelei = uitable(panel_tablicy);
tablica_pokazatelei.Layout.Row = [1, 2];
tablica_pokazatelei.Layout.Column = 1;
tablica_pokazatelei.ColumnName = {'Показатель', 'Значение'};
tablica_pokazatelei.Data = {'Пока нет данных', ''};

panel_knopok = uigridlayout(panel_tablicy, [2, 1]);
panel_knopok.Layout.Row = [1, 2];
panel_knopok.Layout.Column = 2;
panel_knopok.RowHeight = {32, 32};
panel_knopok.ColumnWidth = {'1x'};

knopka_obnovit_grafiki = uibutton(panel_knopok, 'push');
knopka_obnovit_grafiki.Layout.Row = 1;
knopka_obnovit_grafiki.Layout.Column = 1;
knopka_obnovit_grafiki.Text = 'Обновить графики';

knopka_sohranit_grafiki = uibutton(panel_knopok, 'push');
knopka_sohranit_grafiki.Layout.Row = 2;
knopka_sohranit_grafiki.Layout.Column = 1;
knopka_sohranit_grafiki.Text = 'Сохранить графики';

panel_grafikov = uigridlayout(maket, [3, 3]);
panel_grafikov.Layout.Row = 2;
panel_grafikov.Layout.Column = 1;
panel_grafikov.RowHeight = {'1x', '1x', '1x'};
panel_grafikov.ColumnWidth = {'1x', '1x', '1x'};

osi = gobjects(1, 9);
for nomer_osi = 1:9
    osi(nomer_osi) = uiaxes(panel_grafikov);
    osi(nomer_osi).Layout.Row = ceil(nomer_osi / 3);
    osi(nomer_osi).Layout.Column = mod(nomer_osi - 1, 3) + 1;
    title(osi(nomer_osi), sprintf('Показатель %d', nomer_osi));
    grid(osi(nomer_osi), 'on');
end

elementy = struct();
elementy.maket = maket;
elementy.tablica_pokazatelei = tablica_pokazatelei;
elementy.knopka_obnovit_grafiki = knopka_obnovit_grafiki;
elementy.knopka_sohranit_grafiki = knopka_sohranit_grafiki;
elementy.osi = osi;
end
