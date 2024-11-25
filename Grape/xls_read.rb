require 'roo-xls'
xls = Roo::Excel.new('Grape\csv_samples\24R1A1_L_NL6W12Std.xls')
sheet = xls.sheet(0)
header = sheet.row(sheet.header_line)
header[0] =~ /(\S+)[\(,:\[]/
first_name = $1
nitem = header[1..-1].find_index{|f| f =~ /#{first_name}/} + 1
puts nitem
c = []
[0..header.length].each{|i|
  j = i%nitem
  k = sheet.header_line + 1
  if j == 0 
    while sheet.row[i, k] 
      c << sheet.row(k)[i..i+nitem]
      k = k + 1
    end
  end
}
puts c.length