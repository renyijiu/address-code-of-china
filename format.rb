# 读取对应的txt数据，输出适宜使用的格式信息

require 'json'
require 'pp'

class AddressData

  def initialize
    @data = {}
    @current_year = 2018
  end

  def get_output_data
    (1980..@current_year).each do |year|
      read_file(year)
    end

    replace_taiwan_data
    output_hash_data
    output_json_data
    output_latest_address_codes
  end

  private

  def read_file(year)
    file_name = "#{year}.txt"

    File.foreach(file_name) do |line|
      format_line_data(line, year)
    end
  end

  def format_line_data(line, year)
    code, address = line.split(' ')
    p "year: #{year}, code: #{code}, address: #{address}"
    code = code.to_i

    address_arr = @data.fetch(code, [])
    address_info = address_arr.find{ |a| a[:address] == address }
    if address_info.nil?
      tmp_address = {
          address: address,
          start_year: year,
          end_year: year
      }

      @data[code] = address_arr << tmp_address
    else
      index = address_arr.index(address_info)
      address_info[:end_year] = year

      address_arr[index] = address_info
      @data[code] = address_arr
    end
  end

  # 台湾的行政区划代码为710000，但身份证地址码为830000
  def replace_taiwan_data
    @data[830000] = @data.delete(710000) || []
  end

  # 输出hash格式，方便ruby使用
  def output_hash_data
    File.open('hash_data.rb', 'w') do |f|
      PP.pp(@data, f)
    end
  end

  # 输出 json 格式，其他语言通用
  def output_json_data
    File.open('json_data.json', 'w') do |f|
      f.write(JSON.pretty_generate(@data))
    end
  end

  # 输出最新的行政区划代码数组
  def output_latest_address_codes
    data = []

    File.foreach("#{@current_year}.txt") do |line|
      code, _ = line.split(' ')

      # 处理台湾行政区划代码710000，身份证地址码为830000
      code = code.to_i == 710000 ? 830000 : code.to_i
      data << code
    end

    File.open('codes_array.rb', 'w') do |f|
      PP.pp(data, f)
    end
  end

end

a = AddressData.new
a.get_output_data