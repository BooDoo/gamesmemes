class Queneau
  attr_accessor :begin, :middle, :end, :meta
  def initialize(source)
    @begin = []
    @middle = []
    @end = []
    @meta = {
      lengths: []
    }

    if source then
      seed(source)
    end

    return self
  end

  def seed(data, unique: true)
    data.each do |datum|
      words = datum.split.map(&:strip)
      @meta[:lengths].push(words.length)
      first, *rest, last = words
      @begin.push(first)
      @end.push(last)
      @middle.push(*rest)
    end

    if unique
      @begin.uniq!
      @end.uniq!
      @middle.uniq!
    end
  end

  def fill(length=nil)
    length = length || @meta[:lengths].sample + 1
    case length
      when 1
        "#{@begin.sample}"
      when 2
        "#{@begin.sample} #{@end.sample}"
      else
        mids = length - 2
        "#{@begin.sample} #{@middle.sample(mids).join(' ')} #{@end.sample}"
    end
  end
end
