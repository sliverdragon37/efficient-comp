bound = 100000000

max_h :: Int -> [Int] -> Int
max_h x [] = x
max_h x (a : b) = if a > x then max_h a b else max_h x b

list_max :: [Int] -> Int
list_max [] = error "Empty List"
list_max (a : b) = max_h a b

myrange_h :: Int -> [Int] -> [Int]
myrange_h 0 x = 0 : x
myrange_h k x = myrange_h (k-1) (k : x)

mrange_t k = myrange_h (k - 1) []

myrange :: Int -> Int -> [Int]
myrange 0 k = []
myrange x k = k : myrange (x - 1) (k + 1)

mrange :: Int -> [Int]
mrange k = myrange k 0

main = print (list_max (mrange bound))


