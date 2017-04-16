#!/usr/bin/env ruby
# vim:expandtab:shiftwidth=4:tabstop=4:smarttab:autoindent:autoindent

def exitError(message)
    puts message
    return 1
end

exit exitError('Usage: txt2bin.rb infile.txt outfile.bin') if ARGV.length != 2
infile = ARGV[0]
exit exitError("Unable to find input file \"#{infile}\"") if !File.exists?(infile)
f_in = File.open(infile, "rb")
exit exitError("Unable to open input file \"#{infile}\"") if nil == f_in
outfile = ARGV[1]
f_out = File.open(outfile, "wb")
exit exitError("Unable to open out file \"#{outfile}\"") if nil == f_out

def parse_four(line)
    result = Array.new
    pos = 0
    (1..4).each {
        pos = line.index("0x", pos + 1)
        #p pos
        sub_string = line[(pos + 2), 2]
        #p sub_string
        b = [sub_string].pack('H*')
        #p b
        result << b
    }
    return result
end

pages = Array.new

# Parse the input file
f_in.each_line { |line|
    line.strip!
    # For some reason, page 0 doesn't come across in the image dump, but
    # we can infer it from the UID value.
    if nil != line.index("UID Value: ")
        page = parse_four(line)
        page[3] = "\0" # FIXME
        #p page
        pages << page
        next
    end
    if nil != line.index("PAGE") && nil == line.index("PAGE 000:")
        page = parse_four(line)
        #p page
        pages << page
    end
}

# Verify length of parsed data
byte_count = 0
pages.each { |page|
    byte_count += page.length
}
puts("Parsed #{pages.length} pages, #{byte_count} bytes")

#exit exitError("Incorrect number of bytes, expected 572.") if 572 != byte_count

pages.each { |page|
    page.each { |b|
        f_out.write(b)
    }
}

f_in.close()
f_out.close()
