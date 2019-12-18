classdef Visual_traffik_nyvec_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure          matlab.ui.Figure
        UIAxes            matlab.ui.control.UIAxes
        Lamp              matlab.ui.control.Lamp
        Lamp2             matlab.ui.control.Lamp
        Button_3          matlab.ui.control.Button
        KnappLamp         matlab.ui.control.Lamp
        TrafikljusLabel   matlab.ui.control.Label
        KnapptrycktLabel  matlab.ui.control.Label
        NotrunningLabel   matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        end

        % Button pushed function: Button_3
        function ButtonPushed(app, event)
            pause on;
          %  cd ('C:\Program Files\MongoDB\Server\4.2\bin')
          %  system('mongoexport --host=80.217.146.220 --username="igor" --password="igor" --authenticationDatabase admin --collection=resultatBild --db=trafikljus --out=C:\Users\matte\Documents\Trafikljus\camera_data.json --pretty')
          %  system('mongoexport --host=80.217.146.220 --username="igor" --password="igor" --authenticationDatabase admin --collection=resultatLjud --db=trafikljus --out=C:\Users\matte\Documents\Trafikljus\microphone_data.json --pretty')
          %  cd('C:\Users\matte\Documents\Trafikljus')
            [frame_m, events, lengthm, endVal_m] = drop_m(1);
            [frame_c, colours, lengthc, X, Y, W, H, endVal_c] = drop_c(1);
            
            max_d = max([(endVal_m), (endVal_c)]);
            counter_m = 1;
            counter_c = 1;
            app.NotrunningLabel.Text = 'Running';
            
            for i=1:max_d
                %disp(i)
                if i<(endVal_c)
                    if i == frame_c
                        x_C = [];
                        y_C = [];
                        x = [];
                        y = [];
                        w = [];
                        h = [];
                        xw = [];
                        yh = [];
                        x_C(1) = X + W/2;
                        y_C(1) = Y + H/2;
                        x(1) = X;
                        y(1) = Y;
                        w(1) = W;
                        h(1) = H;
                        xw(1) = X + W;
                        yh(1) = Y + H;
                        temp_c = counter_c+1;
                        [frameSen, colours, lengthc, X, Y, W, H] = drop_c(temp_c);
                        p = 2;
                        while frame_c == frameSen
                            x_C(p)= X + W/2;
                            y_C(p)= Y + H/2;
                            x(p) = X;
                            y(p) = Y;
                            w(p) = W;
                            h(p) = H;
                            xw(p) = X + W;
                            yh(p) = Y + H;
                            
                            p = p + 1;
                            temp_c = temp_c+1;
                            [frameSen, colours, lengthc, X, Y, W, H] = drop_c(temp_c);
                            counter_c = temp_c;
                        end
                        m = 0.5;
                        for j=1:length(x)            
                            for k=1:length(x)
                                if(k>j)
                                   % if(j<length(x) && k<length(x))
%                                     disp(j)
%                                     disp('j')
%                                     disp(k)
%                                     disp('k')
%                                     disp(length(x))
%                                     disp('lagnangansd')
                                    if (((abs(x_C(j)-x_C(k)) <= w(j)*m) && (abs(y_C(j)-y_C(k)) <= h(j)*m)) || ((abs(x_C(j)-x_C(k)) <= w(k)*m) && (abs(y_C(j)-y_C(k)) <= h(k)*m)))
                                        x_C(k)= -100;
                                        y_C(k)= -100;
                                        x(k) = 0;
                                        y(k) = 0;
                                        w(k) = 0;
                                        h(k) = 0;
                                        xw(k) = 0;
                                        yh(k) = 0;
                                    end
                                   % end
                                end
                            end
                        end
                        
                        
                        plot(app.UIAxes, x_C, y_C,'o');
                        
                        counter_c = temp_c;
                        [frame_c, colours, lengthc, X, Y, W, H] = drop_c(counter_c);
                    end
                end
                if i<(endVal_m)
                    if i==frame_m
                        
                        if  ismember(events,'Green')
                            app.Lamp2.Visible = 'off';
                            app.Lamp.Visible = 'on';
                            app.KnappLamp.Visible = 'off';
                            
                        else
                            app.Lamp2.Visible = 'on';
                            app.Lamp.Visible = 'off';
                        end
                        if  ismember(events,'Button_pressed')
                            app.KnappLamp.Visible = 'on';
                        end
                        counter_m = counter_m + 1;
                        [frame_m, events, lengthm] = drop_m(counter_m);
                    end
                end
                pause(0.001);
            end
            
        
        app.NotrunningLabel.Text = 'No data left';
    
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 537 458];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Position')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [1.21114369501466 1 1];
            app.UIAxes.XLim = [0 640];
            app.UIAxes.YLim = [0 480];
            app.UIAxes.YDir = 'reverse';
            app.UIAxes.ALim = [0 1];
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.BackgroundColor = [1 1 1];
            app.UIAxes.Position = [1 131 374 328];

            % Create Lamp
            app.Lamp = uilamp(app.UIFigure);
            app.Lamp.BusyAction = 'cancel';
            app.Lamp.Visible = 'off';
            app.Lamp.Position = [488 370 20 20];

            % Create Lamp2
            app.Lamp2 = uilamp(app.UIFigure);
            app.Lamp2.BusyAction = 'cancel';
            app.Lamp2.Position = [489 401 20 20];
            app.Lamp2.Color = [1 0 0];

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button_3.Position = [19 20 100 29];

            % Create KnappLamp
            app.KnappLamp = uilamp(app.UIFigure);
            app.KnappLamp.Visible = 'off';
            app.KnappLamp.Position = [488 306 20 20];
            app.KnappLamp.Color = [0 0 1];

            % Create TrafikljusLabel
            app.TrafikljusLabel = uilabel(app.UIFigure);
            app.TrafikljusLabel.Position = [471 428 53 22];
            app.TrafikljusLabel.Text = 'Trafikljus';

            % Create KnapptrycktLabel
            app.KnapptrycktLabel = uilabel(app.UIFigure);
            app.KnapptrycktLabel.Position = [462 333 72 22];
            app.KnapptrycktLabel.Text = 'Knapp tryckt';

            % Create NotrunningLabel
            app.NotrunningLabel = uilabel(app.UIFigure);
            app.NotrunningLabel.Position = [138 21 118 26];
            app.NotrunningLabel.Text = 'Not running';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Visual_traffik_nyvec_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end