require 'grape'
$:.unshift File.join(ENV['HOME'].gsub(/\\/, '/'), '/work/alb2/lib')
$:.unshift '.'
puts "hello world from ruby"
# puts $:
require 'j_pack'

module Test
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

    resource :ltspctl do
      desc 'Open LTspice'
      get :open do
        work_dir = URI.decode_www_form_component(params[:dir] || ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/')
        ckt_name = URI.decode_www_form_component(File.join(work_dir, params[:file] || 'tsd_TEG_tb.asc'))
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          ckt.open
          {"elements" => ckt.elements, "info" => ckt.info}
        } 
        end
      desc 'Simulate'
      get :simulate do
        work_dir = URI.decode_www_form_component(params[:dir] || ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/')
        ckt_name = URI.decode_www_form_component(File.join(work_dir, params[:file] || 'tsd_TEG_tb.asc'))
        probes = params[:probes] ? URI.decode_www_form_component(params[:probes]): nil
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          ckt.simulate
          if probes
            vars, traces = ckt.get_traces probes
            {"vars" => vars, "traces" => traces}
          else
            {"log" => ckt.sim_log}
          end
          }
        end
      desc 'Results'
      get :results do
        work_dir = URI.decode_www_form_component(params[:dir] || ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/')
        ckt_name = URI.decode_www_form_component(File.join(work_dir, params[:file] || 'tsd_TEG_tb.asc'))
        probes = params[:probes] ? URI.decode_www_form_component(params[:probes]): nil
        Dir.chdir(work_dir){
          ckt = LTspiceControl.new(File.basename ckt_name)
          vars, traces = ckt.get_traces probes
          {"vars" => vars, "traces" => traces}
        }
      end
    end
  end
end