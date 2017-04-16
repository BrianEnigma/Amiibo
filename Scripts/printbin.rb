#!/usr/bin/env ruby
# vim:expandtab:shiftwidth=4:tabstop=4:smarttab:autoindent:autoindent
require 'set'

def exitError(message)
    puts message
    return 1
end

class Ntag215
    LineMapping = {
        0x00 => "serial number, part 1",
        0x01 => "serial number, part 2",
        0x02 => "serial number check and static lock bits",
        0x03 => "Capability Container (CC)",
        0x15 => "Amiibo identifier, part 1",
        0x16 => "Amiibo identifier, part 2",
        0x82 => "dynamic lock bits",
        0x83 => "configuration page 1",
        0x84 => "configuration page 2",
        0x85 => "configuration page 3",
        0x86 => "configuration page 4",
    }
    def initialize()
        @pages = Array.new
        @serial = String.new
        @lockedPages = Set.new
    end
    
    def readFile(f)
        while page = f.read(4)
            @pages << page
        end
        parseAll()
    end
    
    def parseAll()
        parseSerial()
        parseStaticLockBits()
        parseDynamicLockBits()
    end
    
    def parseSerial()
        @serial << @pages[0][0]
        @serial << @pages[0][1]
        @serial << @pages[0][2]
        @serial << @pages[1][0]
        @serial << @pages[1][1]
        @serial << @pages[1][2]
        @serial << @pages[1][3]
    end
    
    def parseStaticLockBits()
        # Deal with blocks
        @lockedPages << 3 if 0x00 != 0x01 & @pages[2][2].ord
        if 0x00 != 0x02 & @pages[2][2].ord
            (4..9).each { |i|
                @lockedPages << i
            }
        end
        if 0x00 != 0x03 & @pages[2][2].ord
            (10..15).each { |i|
                @lockedPages << i
            }
        end
        # Deal with individual pages
        (3..7).each { |i|
            @lockedPages << i if 0x00 != (0x01 << i) & @pages[2][2].ord
        }
        (8..15).each { |i|
            @lockedPages << i if 0x00 != (0x01 << (i - 8)) & @pages[2][3].ord
        }
    end
    
    def parseDynamicLockBits()
        # Granularity of 16 pages
        startLockPage = 16
        (0..7).each { |i|
            if 0x00 != (0x01 << (i - 8)) & @pages[0x82][0].ord
                (startLockPage...(startLockPage + 16)).each { |pg|
                    @lockedPages << pg
                }
            end
            startLockPage += 16
        }
        # Other page ranges
        if 0x00 != 0x01 & @pages[0x82][2].ord
            (16..47).each { |i|
                @lockedPages << i
            }
        end
        if 0x00 != 0x02 & @pages[0x82][2].ord
            (48..79).each { |i|
                @lockedPages << i
            }
        end
        if 0x00 != 0x04 & @pages[0x82][2].ord
            (80..111).each { |i|
                @lockedPages << i
            }
        end
        if 0x00 != 0x08 & @pages[0x82][2].ord
            (112..129).each { |i|
                @lockedPages << i
            }
        end
    end
    
    def printHex(a)
        a.each_byte { |b|
            printf(" 0x%02X", b)
        }
    end
    
    def debugPrint()
        counter = 0
        puts("UID Length: #{@serial.length} bytes")
        print("UID Value:")
        printHex(@serial)
        print("\n")
        
        puts("Found #{@pages.length} pages (#{4 * @pages.length} bytes):")
        puts("")
        @pages.each { |page|
            comments = ''
            printf("PAGE %03d:", counter)
            printHex(page)
            comments << "[LOCKED] " if @lockedPages.member?(counter)
            comments << LineMapping[counter] if LineMapping.has_key?(counter)
            print("    # #{comments}") if !comments.empty?
            print("\n")
            counter += 1
        }
    end
end

# Setup
exit exitError('Put *.bin file to read on the command line.') if ARGV.length != 1
filename = ARGV[0]
exit exitError("Unable to find file \"#{filename}\"") if !File.exists?(filename)
f = File.open(filename, "rb")
exit exitError("Unable to open file \"#{filename}\"") if nil == f

# Parse
tag = Ntag215.new
tag.readFile(f)
f.close()

# Do things
tag.debugPrint()

