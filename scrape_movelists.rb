require 'open-uri'
require 'nokogiri'
require 'json'

MOVELIST_SEARCH_URL_SF = "http://streetfighter.wikia.com/wiki/Special:Search?search=%22list+of+moves%22&fulltext=Search"
MOVELIST_INDEX_URL_GGXX = "http://guilty-gear.wikia.com/wiki/Command_List"

# get move lists from streetfighter.wikia.com
def get_movelist_urls_sf(search_url)
  results = Nokogiri::HTML(open(MOVELIST_SEARCH_URL_SF))
  result_links = results.css('li.result > article > h1 > a')
  movelist_urls = result_links.select{ |el|
    el.text.downcase.include? "list of moves"
  }.map{ |el|
    el.attribute('href').value
  }
end

def extract_moves_sf(doc)
  # get first item from each row of move tables, remove prefix
  doc.css('table.wikitable > tr > td:first-child')[1..-1].map(&:text).map(&:strip).map{ |n|
    n.gsub(/.+: |\(.+?\)/, '').strip
  }
end

def get_movelist_urls_ggxx(index_url=MOVELIST_INDEX_URL_GGXX)
  results = Nokogiri::HTML(open(index_url))
  result_links = results.css('span.box.headnote a')
  movelist_urls = result_links.map{ |el|
    href = el.attribute('href').value
    URI.join(index_url, href).to_s
  }
end

def extract_moves_ggxx(doc)
  doc.css('td:last-child').map(&:text).map(&:strip).map{ |n|
    n.gsub(/: .+|\(.+?\)/, '').strip
  }
end

movelist_urls_sf = get_movelist_urls_sf(MOVELIST_SEARCH_URL_SF)
movelist_urls_ggxx = get_movelist_urls_ggxx(MOVELIST_INDEX_URL_GGXX)
# read each URL into a Nokogiri document
docs_sf = movelist_urls_sf.map {|url|
          Nokogiri::HTML(open(url))
       }

moves_sf = docs_sf.map(&method(:extract_moves_sf)).reduce(:+).select{|n| !n.include? "/"}.uniq

docs_ggxx = movelist_urls_ggxx.map { |url|
          Nokogiri::HTML(open(url))
      }

moves_ggxx = docs_ggxx.map(&method(:extract_moves_ggxx)).reduce(:+).select{|n| !n.include? "/"}.uniq

moves = moves_sf + moves_ggxx

p File.write('movelist.json', JSON.fast_generate(moves))
p moves
