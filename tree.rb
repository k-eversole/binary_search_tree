require_relative 'node'

class Tree
  attr_accessor :root, :sorted
  def initialize(array)
    @sorted = array.sort.uniq
    @root = build_tree(sorted)

  end

  def build_tree(array)
    return nil if array.empty?

    middle = (array.length - 1)/2
    base_node = Node.new(array[middle])

    base_node.left = build_tree(array[0...middle])
    base_node.right = build_tree(array[(middle + 1)...array.length])

    base_node
  end

  def insert(value, node = root)
    return Node.new(value) if node.nil?

    return nil if value == node.data

    if value > node.data
      node.right = insert(value, node.right)
    else
      node.left = insert(value, node.left)
    end
    node
  end

  def delete(value, node = root)
    return node if node.nil?

    if value > node.data
      node.right = delete(value, node.right)
    elsif value < node.data
      node.left = delete(value, node.left)

    else
      return node.right if node.left.nil?
      return node.left if node.right.nil?

      successor = find_leftmost(node)
      node.data = successor.data
      node.left = delete(successor.data, node.left)
    end
    node
  end

  def find_leftmost(node = root)
    node = node.left until node.left.nil?
    node
  end

  def find(value, node=root)
    return node if node.data == value

    node.data > value ? find(value, node.left) : find(value, node.right)
  end

  def level_order
    array = []
    queue = []
    queue << root

    until queue.empty?
      node = queue.shift
      array << node.data
      queue << node.left unless node.left.nil?
      queue << node.right unless node.right.nil?
      yield(node) if block_given?
    end
    array
  end

  def inorder(node = root, array = [], &block)
    return if node.nil?

    inorder(node.left, array, &block)
    yield(node) if block_given?
    array << node.data
    inorder(node.right, array, &block)
    array
  end

  def preorder(node = root, array = [], &block)
    return if node.nil?

    yield(node) if block_given?
    array << node.data
    preorder(node.left, array, &block)
    preorder(node.right, array, &block)
    array
  end

  def postorder(node = root, array = [], &block)
    return if node.nil?

    postorder(node.left, array, &block)
    postorder(node.right, array, &block)
    yield (node) if block_given?
    array << node.data
    array
  end

  def height(node = root)
    return -1 if node.nil?

    left_height = height(node.left)
    right_height = height(node.right)
    [left_height, right_height].max + 1
  end

  def depth(node)
    return nil if node.nil?

    current = @root
    count = 0
    until current.data == node.data
      count += 1
      if node.data < current.data
        current = current.left
      else
        current = current.right
      end
    end
    count
  end

  def balanced?(node = root)
    return true if node.nil?

    left = height(node.left)
    right = height(node.right)
    (left - right).abs <= 1 && balanced?(node.left) && balanced?(node.right)
  end

  def rebalance
    self.sorted = inorder
    self.root = build_tree(sorted)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

binary = Tree.new((Array.new(15) { rand(1..100) }))

puts  binary.balanced?

p binary.level_order
p binary.preorder
p binary.inorder
p binary.postorder

5.times do
  number = rand(100..200)
  binary.insert(number)
  puts "Inserted #{number}"
end

puts binary.balanced?

binary.rebalance

puts binary.balanced?

p binary.level_order
p binary.preorder
p binary.inorder
p binary.postorder\