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
        $work_dir = params[:dir] || ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/'
        $ckt_name = File.join($work_dir, params[:file] || 'tsd_TEG_tb.asc')
        Dir.chdir($work_dir){
          ckt = LTspiceControl.new(File.basename $ckt_name)
          ckt.open
          {"elements" => ckt.elements, "info" => ckt.info}
        } 
        end
      desc 'Simulate'
      get :simulate do
        $work_dir = params[:dir] || ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/'
        $ckt_name = File.join($work_dir, params[:file] || 'tsd_TEG_tb.asc')
        Dir.chdir($work_dir){
          ckt = LTspiceControl.new(File.basename $ckt_name)
          ckt.simulate
          {"end" => "end"}
        }
       end
    end
  end
end