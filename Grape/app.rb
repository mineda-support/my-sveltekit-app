require 'grape'
#$:.unshift File.join(ENV['HOME'].gsub(/\\/, '/'), '/work/alb2/lib')
$:.unshift File.join('..', 'j_pack')
$:.unshift '.'
puts "hello world from ruby"
# puts $:
require 'j_pack'
require 'byebug'
require './csv_read'

module Test
  class Utils
    def self.get_params params
      work_dir = params[:dir] || ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/'
      ckt_name = File.join(work_dir, params[:file] || 'tsd_TEG_tb.asc')
      [work_dir, ckt_name] 
    end
    def self.shift360 p
      if p > 30
        p = p -360
      end
      p
    end
  end
  class API < Grape::API
    format :json
    prefix :api

    resource :blog do
      desc 'Return an article.'
      get :article do
        {
          "title" => "title",
          "body" => "body"
        }
      end
    end

    resource :misc do
      desc 'Load program'
      get :load do
        dir, file = Utils::get_params(params)
        load File.join(dir, file)
        {}
      end
      desc 'Get measured data'
      get :measured_data do
        measfile = params[:file]
        reject_list = params[:reject].split(/[, ]/).map{|a| a.to_i - 1}
        puts "Get measured data from #{measfile}"
        c = CSV.read(measfile)
        d = valid_data c, reject_list
        {"traces" => d}
      end      
    end
    
    resource :ltspctl do
      desc 'Open LTspice'
      get :open do
        work_dir, ckt_name = Utils::get_params(params)
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename(ckt_name), true)
          ckt.open(File.basename(ckt_name), true) if params[:showup]
          puts ckt.elements
          {"elements" => ckt.elements, "info" => ckt.info}
        } 
        end
      desc 'Simulate'
      get :simulate do
        work_dir, ckt_name = Utils::get_params(params)
        probes = params[:probes] 
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          ckt.simulate
          if probes
            vars, traces = ckt.get_traces *(probes.split(','))
            if probes.start_with? 'frequency'
              db = traces.map{|trace| {name: trace[:name], x: trace[:x], y: trace[:y].map{|a| 20.0*Math.log10(a.abs)}}}
              phase = traces.map{|trace| {name: trace[:name], x: trace[:x], y: trace[:y].map{|a| Utils::shift360(a.phase*(180.0/Math::PI))}}}
              {"vars" => vars, "db" => db, "phase" => phase}
            else
              {"vars" => vars, "traces" => traces}
            end 
          else
            {"log" => ckt.sim_log}
          end
          }
        end
      desc 'Results'
      get :results do
        work_dir, ckt_name = Utils::get_params(params)
        #probes = params[:probes] ? URI.decode_www_form_component(params[:probes]): nil
        probes = params[:probes] 
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          if probes
            vars, traces = ckt.get_traces *(probes.split(','))
            if probes.start_with? 'frequency'
              db = traces.map{|trace| {name: trace[:name], x: trace[:x], y: trace[:y].map{|a| 20.0*Math.log10(a.abs)}}}
              phase = traces.map{|trace| {name: trace[:name], x: trace[:x], y: trace[:y].map{|a| Utils::shift360(a.phase*(180.0/Math::PI))}}}
              {"vars" => vars, "db" => db, "phase" => phase}
            else
              {"vars" => vars, "traces" => traces}
            end 
          else
            {"log" => ckt.sim_log}
          end
        }
      end
      desc 'Updates'
      get :update do
        work_dir, ckt_name = Utils::get_params(params)
        updates = eval params[:updates]
        puts "updates: #{updates}"
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          ckt.set updates
          {"elements" => ckt.elements, "info" => ckt.info}
        }
      end
      desc 'Info'
      get :info do
        work_dir, ckt_name = Utils::get_params(params)
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          {"info" => ckt.info}
        }
      end
      desc 'Convert_from_LTspice'
      post :convert_from_LTspice do
        # puts params
        # puts params.keys
   
        load 'ltspice.rb'
        load 'qucs.rb'
        load 'xschem.rb'
        load 'eeschema.rb'
        load 'alta.rb'
        load 'ltspctl.rb'
        load 'ngspice.rb'
        load 'ngspctl.rb'
        load 'qucsctl.rb'
        work_dir, ckt_name = Utils::get_params(params)
        Dir.chdir(work_dir){
          puts 'execute under' + work_dir
          puts params[:program]
          eval params[:program]
        }
      end
      desc 'Execute program'
      post :execute do
        # puts params.keys
        # puts params
        work_dir, ckt_name = Utils::get_params(params)
        Dir.chdir(work_dir){
          puts params[:program]
          ckt = LTspiceControl.new(File.basename ckt_name)
          new_traces = eval params[:program]
          {"traces" => new_traces}
        }
      end
      desc 'Measurement'
      post :measure do
        require 'json'
        # puts params.keys
        # puts params
        work_dir, ckt_name = Utils::get_params(params)
        results = []
        Dir.chdir(work_dir){
          puts params[:equation]
          ckt = LTspiceControl.new(File.basename ckt_name)
          # puts params[:plotdata].inspect
          puts params[:plotdata].size
          params[:plotdata].each{|plotdata|
            # debugger
            # puts plotdata[:x]
            # puts plotdata[:y]
            x = Array_with_interpolation.new plotdata[:x]
            y = Array_with_interpolation.new plotdata[:y]
            begin
              results << eval(params[:equation])
            rescue
              results << nil
            end
          }
          {"calculated_value" => results}
        }
      end
    end
  end
end
