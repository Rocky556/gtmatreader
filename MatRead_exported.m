classdef MatRead_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MortgageCalculatorUIFigure  matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        BrowserButton               matlab.ui.control.Button
        RedDropDownLabel            matlab.ui.control.Label
        RedDropDown                 matlab.ui.control.DropDown
        GreenDropDownLabel          matlab.ui.control.Label
        GreenDropDown               matlab.ui.control.DropDown
        BlueDropDownLabel           matlab.ui.control.Label
        BlueDropDown                matlab.ui.control.DropDown
        LoadButton                  matlab.ui.control.Button
        RightPanel                  matlab.ui.container.Panel
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.MortgageCalculatorUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {496, 496};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {164, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        % Callback function
        function MonthlyPaymentButtonPushed(app, event)
                       
            % Calculate the monthly payment
            amount = app.LoanAmountEditField.Value ;
            rate = app.InterestRateEditField.Value/12/100 ;
            nper = 12*app.LoanPeriodYearsEditField.Value ;
            payment = (amount*rate)/(1-(1+rate)^-nper);
            app.MonthlyPaymentEditField.Value = payment;
            
            % pre allocating and initializing variables 
            interest = zeros(1,nper);
            principal = zeros(1,nper);
            balance = zeros (1,nper);
            
            balance(1) = amount;
            
            % Calculate the principal and interest over time
            for i = 1:nper
                interest(i)  = balance(i)*rate ;
                principal(i) = payment - interest(i) ;
                balance(i+1) = balance(i) - principal(i) ;
            end
            
            % Plot the principal and interest
            plot(app.PrincipalInterestUIAxes, (1:nper)', principal, ...
                (1:nper)', interest) ;
            legend(app.PrincipalInterestUIAxes,{'Principal','Interest'},'Location','Best')
            xlim(app.PrincipalInterestUIAxes,[0 nper]) ; 
            
        end

        % Button pushed function: BrowserButton
        function BrowserButtonPushed(app, event)
         try    
            [filename, pathname] = uigetfile({'*.mat','Matlab';'*.*','All Files' }); %Open the file selection interface
            load(filename);
            
            %Judge file format
            if ~exist('A')
                cla(app.UIAxes);
                cla(app.UIAxes2);
                app.RedDropDown.Visible=false;
                app.RedDropDownLabel.Visible=false;
                app.BlueDropDown.Visible=false;
                app.BlueDropDownLabel.Visible=false;
                app.GreenDropDown.Visible=false;
                app.GreenDropDownLabel.Visible=false;
                app.LoadButton.Visible=false;
                %Delete file suffix
                filename=lower(filename);
                file=find('.'==filename);
                filename = filename(1:file-1);
                data=eval(filename);
                subsetData=data(data>0.5);
                
                %Definition the drawing matrix
                [r,c]=size(data);
                A=zeros(r,c,3);
                max1=max(max(data));
                app.UIAxes.XTick=1:max1;
                app.UIAxes.XTickLabel=1:max1;
                app.UIAxes.XLabel.String="Classes";
                app.UIAxes.YLabel.String="Samples";
                histogram(app.UIAxes,subsetData);
                for i = 1 : max1
                    temp=find(data==i);
                    %Randomly assign colors
                    for ii=temp
                        A(ii)=255*rand;
                        A(ii+numel(data))=255*rand;
                        A(ii+2*numel(data))=255*rand;
                    end
                end
                imshow(uint8(A),[],'parent',app.UIAxes2);
            else
                cla(app.UIAxes);
                cla(app.UIAxes2);
                app.RedDropDown.Visible=true;
                app.RedDropDownLabel.Visible=true;
                app.BlueDropDown.Visible=true;
                app.BlueDropDownLabel.Visible=true;
                app.GreenDropDown.Visible=true;
                app.GreenDropDownLabel.Visible=true;
                app.LoadButton.Visible=true;
                
                
                [r,c]=size(A); %Get the number of bands and image size
                nRow=sqrt(c);
                nCol=sqrt(c);
                nEnd=r;
                [R,~]=size(M);
                
                app.UIAxes.XTick=1:10:R;
                app.UIAxes.XTickLabel=1:10:R;
                app.UIAxes.XLabel.String="Bands";
                app.UIAxes.YLabel.String="Reflectance";
                
                
                %Draw the line chart of Reflectance
                for i = 1 : nEnd
                    plot(app.UIAxes,M(:,i));
                    hold (app.UIAxes,'on');
                end
                legend(app.UIAxes,cood); %Add a legend
            
                %update the DropDown data
                app.RedDropDown.Items=cood;
                app.GreenDropDown.Items=cood;
                app.BlueDropDown.Items=cood;
            
                %DropDown data connect value
                for ii= 1 : nEnd
                    app.RedDropDown.ItemsData(ii)=ii;
                    app.GreenDropDown.ItemsData(ii)=ii;
                    app.BlueDropDown.ItemsData(ii)=ii;
                end
            
                %Defining global variables
                global AA;
                AA=A;
                global Row;
                Row=nRow;
                global Col;
                Col=nCol;
            end
          catch Me
              msgbox(Me.message);
          end
        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
        %Get global variables
        global AA;global Row;global Col;
        
        %Image synthesis
        try
            %Two-dimensional matrixs of three bands synthesis a Three-dimensional matrix
            aa(:,:,1)=reshape (AA(app.RedDropDown.Value,:), [Row Col])*255;
            aa(:,:,2)=reshape (AA(app.GreenDropDown.Value,:), [Row Col])*255;
            aa(:,:,3)=reshape (AA(app.BlueDropDown.Value,:), [Row Col])*255;
            %Draw an image
            imshow(uint8(aa),[],'parent',app.UIAxes2);
        catch Me
            msgbox(Me.message);
        end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MortgageCalculatorUIFigure and hide until all components are created
            app.MortgageCalculatorUIFigure = uifigure('Visible', 'off');
            app.MortgageCalculatorUIFigure.AutoResizeChildren = 'off';
            app.MortgageCalculatorUIFigure.Position = [100 100 752 496];
            app.MortgageCalculatorUIFigure.Name = 'Mortgage Calculator';
            app.MortgageCalculatorUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.MortgageCalculatorUIFigure);
            app.GridLayout.ColumnWidth = {164, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.Scrollable = 'on';

            % Create BrowserButton
            app.BrowserButton = uibutton(app.LeftPanel, 'push');
            app.BrowserButton.ButtonPushedFcn = createCallbackFcn(app, @BrowserButtonPushed, true);
            app.BrowserButton.Position = [11 390 142 39];
            app.BrowserButton.Text = 'Browser';

            % Create RedDropDownLabel
            app.RedDropDownLabel = uilabel(app.LeftPanel);
            app.RedDropDownLabel.HorizontalAlignment = 'right';
            app.RedDropDownLabel.Position = [1 282 65 25];
            app.RedDropDownLabel.Text = 'Red';

            % Create RedDropDown
            app.RedDropDown = uidropdown(app.LeftPanel);
            app.RedDropDown.Items = {};
            app.RedDropDown.Position = [80 285 73 22];
            app.RedDropDown.Value = {};

            % Create GreenDropDownLabel
            app.GreenDropDownLabel = uilabel(app.LeftPanel);
            app.GreenDropDownLabel.HorizontalAlignment = 'right';
            app.GreenDropDownLabel.Position = [1 222 65 22];
            app.GreenDropDownLabel.Text = 'Green';

            % Create GreenDropDown
            app.GreenDropDown = uidropdown(app.LeftPanel);
            app.GreenDropDown.Items = {};
            app.GreenDropDown.Position = [80 222 73 22];
            app.GreenDropDown.Value = {};

            % Create BlueDropDownLabel
            app.BlueDropDownLabel = uilabel(app.LeftPanel);
            app.BlueDropDownLabel.HorizontalAlignment = 'right';
            app.BlueDropDownLabel.Position = [2 164 65 22];
            app.BlueDropDownLabel.Text = 'Blue';

            % Create BlueDropDown
            app.BlueDropDown = uidropdown(app.LeftPanel);
            app.BlueDropDown.Items = {};
            app.BlueDropDown.Position = [81 164 72 22];
            app.BlueDropDown.Value = {};

            % Create LoadButton
            app.LoadButton = uibutton(app.LeftPanel, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [11 63 142 39];
            app.LoadButton.Text = 'Load';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.Scrollable = 'on';

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'Bands')
            ylabel(app.UIAxes, 'Reflectance')
            app.UIAxes.XTick = [0 20 40 60 80 100 120 140 160 180 200];
            app.UIAxes.XTickLabel = {'0'; '20'; '40'; '60'; '80'; '100'; '120'; '140'; '160'; '180'; '200'};
            app.UIAxes.TitleFontWeight = 'bold';
            app.UIAxes.Position = [23 243 531 223];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.RightPanel);
            title(app.UIAxes2, '')
            xlabel(app.UIAxes2, '')
            ylabel(app.UIAxes2, '')
            app.UIAxes2.XColor = 'none';
            app.UIAxes2.XTick = [];
            app.UIAxes2.YColor = 'none';
            app.UIAxes2.YTick = [];
            app.UIAxes2.TitleFontWeight = 'bold';
            app.UIAxes2.Position = [23 23 531 200];

            % Show the figure after all components are created
            app.MortgageCalculatorUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MatRead_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MortgageCalculatorUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MortgageCalculatorUIFigure)
        end
    end
end