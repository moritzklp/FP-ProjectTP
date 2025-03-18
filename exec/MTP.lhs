\section{Multi Time Pad}

When the same key $k$ is reused for multiple messages $m_1, m_2$:
\begin{align*}
c_1 &= m_1 \oplus k \\
c_2 &= m_2 \oplus k
\end{align*}

An attacker can compute:
\[ c_1 \oplus c_2 = (m_1 \oplus k) \oplus (m_2 \oplus k) = m_1 \oplus m_2 \]

This eliminates the key and reveals the XOR of plaintexts. While $m_1 \oplus m_2$ isn't immediately readable, attackers can use frequency analysis and known plaintext patterns to recover both messages \cite{Denning83}. \\

For example: 

Consider two messages encrypted with the same key:
\begin{align*}
m_1 &= \texttt{"HelloWorld"} \\
m_2 &= \texttt{"SecureData"} \\
k &= \texttt{0x5f1d3a...} \quad\text{(random bytes)}
\end{align*}

The attacker observes:
\begin{align*}
c_1 &= m_1 \oplus k \\
c_2 &= m_2 \oplus k
\end{align*}

By computing $c_1 \oplus c_2$, the attacker gets $m_1 \oplus m_2$. If they guess part of $m_1$ (e.g., common phrase "Hello"), they can recover the corresponding part of $m_2$:
\[ \text{Guessed } m_1 \oplus (m_1 \oplus m_2) = m_2 \]



\section{Many Time Pad Attack}
As previously stated, the One Time Pad is secure and resistant to attacks. However, in case where not all the keys are unique, so a key is reused, it is possible to break the encyption. The method to do it is called a Many Time Pad Attack.
The cipher becomes vulnerable because if two plaintexts have been ecypted with the same key, performing the XOR operation on the cipher-texts will have the same result as doing it with the original plaintexts. What it means is that we remove the secret key from the equation completely. This is shown in the equation: [insert equation]


\begin{code}
module MTP where

import System.Environment (getArgs)
import Data.Char (chr, ord, isAscii)
import Data.Word (Word8)
import Data.Bits (xor)
import Data.List (intercalate, foldl')
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8
import Text.Printf (printf)
\end{code}

\begin{code}

-- Encrypted messages from the challenge pdf
encryptedMessages :: [String]
encryptedMessages = ["d9dd0e68af89e6447cec0b107e576f20ec64ada45c3cd7b5ccbd27bc3ffe73ddf8a38ff374fa4527edcf3eb69642ad733468596480aff8c6890d006d933eae7825c77041c49337b5bd8f658b3141ca9dc6b614348c2e39a3d7eaf0808b94ad062c72dbd9a0cd28c100b018d8fea5464c863b03997a84c7a0ef6405e49f41f821bdd3c6596237eaa288dd1ee21154ce70da62bb0f0b0c71935ddb0db4446c99aab7808ac3fa724cc3",
    "dac61668b0dfa37360fc18192a043c2ea062a9f75f2fdfb280916aa86baa34d5f3a795f278f30033b18a0da99d5de462302d067f9ab1efbcde36487cdb27a16b3ec77e5581c736befb9462852d5095d2c7ad5179982e70bcc1b8e180d890b74263748ed5adcf28c11da10dc2baae4b15c97307d777caebf6f72d1fe28e12ab3ba99692506578ecb3c4cf1ff45901c177c827bd140b0225c70ffb0fb8583e82ecd28c92d9e23748c8a893",
    "ddd2142daa8ba37761f701462d2c6f26ee75a1ea4b139880c8bd24aa72bb6698faa39ce531ee0023ec8a31bc8d16e9682b631407d2f3f6b2bc104f6e9577a17132c7655bc8dd39a8fb956e87280498dcc0ba517b8b6024bac7ffebc5ca9ba7427c7fc1c4adc628d306a048c2eeb9425cd93742987ccae1ffeb2b1ef8cb0ef974abd7804c2039f1b288d019f21147c57cc027bd140f5671c712ef46a0443e85eb96c995c5e763408da3d3a3a67bbb55",
    "c7c60a7da2c5c44666fe041d60576f3bf97eada46b2fd6b0ceb927ef77aa6dd4f3eab3a07de61332bfcb68bf9952f4272b655b6ac9f3f8e59f104d399a39a43f35887c43c0c02db2b4886a96200492c492ba106dd56011f5d1f4e296d88ce3056568c294b6cb67921fab07c6baa45d429d6f0dd77bcae4e8fb641fe38e41ed26aad382576d78f0b088c856e444518076ca27aa13084434db5ddb41b1486c81aa85818bc3eb374dc8a7cfb8f37bb60038125bdb853476eee1c3922d7709e4be6c2b9e485b42af0b284c4efb40f27049cea7cdab340277bdf5830a8e8c734691eb23b66b6e5ca273",
    "c7f6295986b7d56e44d52f502d387426ef32e5a47c3cdda4c9bc2fa170fe5bdaf7a79ba070e70177d2c33ca7d864e26a32684d6ac1f2bdb28e0e55779c3eae78768e7f47ce932ab3bec66d8b2b459c9ddcb71f71d92431acc1b8ec838b94e30f7976dadda3ca64de1daa069cfea35e59dc6942876cc1fdeee62105ff8200e774bdd7855d203ef0b5ddda13e3114fcf6d8c68a71017023ed05dee09b3016d88fc9787c4dde164518da5d2a1a379a71d3f5b45d1d13367fdb5d18964394bffa32b22861b570dad007b0e6eaf53f767429cbfd1b1380260bae1995e8c806e02c6ed31fe767715a56f6e65df2158e653d428bcf8b1cba3b3ecad0ed5f56d36c846ca5023a4166751151cef3cc6fd5d88d09f638e03dd61bbc17bc2defdd450096a384db3e2b08d",
    "dfdf1e2d8e84e06367f70b106957742ee432a9a44a2fcaba8cf80faa24b734ddf3ea93a07ee14477dec42cf39758ad73346c406ac6e1aaffde0a45399336a43f25887c5681d036b2b88d6e8c3608d0f8d7fe18349c2570bc92f7ebc48ba2aa16643acf94a2cf7dd11fe80bddefaf5915d57e10923284cfe9e6640aab880dfe37a49b8554753bf4f6dcc113f5540f8051c975ac5c0f0232d208f90afa016a85ef808cc4d1ae7449d8a5d6e0f359a511394b44dc943276bca09499246c4ae1fa682f9f0b53",
    "d9c05a79ab8cf0077cf10f5c7f127d23a07ea1e24971989ed3f83ea76dad34d2e3b98ea077e80b23fed931ecd875ec723b65406ac9eef8f3de0e41779f24ac7632823d13efdc7ebea8856a92200496cfddb351669c213cbcc6e1adc5e485a60c2c63c1c1b3836dcb11b64491d6a35d5e9d6e12d76acbaef3ea214bf88008ee27efd7885c202bfab384893fa05c01ca6cdf73e91d4e523ed10fba03b95832cdc3d28781d5ea374bc2e6ceb5be6cb200234b1d94b32570fdb4c79f68500ee7f76e229911184ead033e402fbe46e87b0589bf88ff104b77a1f8920a8d8c7a4a9da429ff6b6d59b4276767887b",
    "c7d65d7fa6c5f04828fe061d69576820a061ade10c3dd7f7cdb924b624b17298efa58fa07de61332f3d368a39d59fd6b392d5c2fd2e5f8e6910c497e9323ee3f17897513d6d67eacb4936786654183cdd7bd1875952c29f5def1e8808b81ac427b7fc2d7aece6d9215a90491eea45715cf7e12857bd7ebe9f6251fe29d04f874a0d0c6716c34f6b8c7c005a04201cc78db27ac12084d23dd18f704b8553e8ee59f8491dee7635c8db2d5ada73cbb153d5713d7992f60f9af948e273943e5be65639f1b1845a71c3e4c66b507ef6a40ce80c5b33d4166f5dc985e80893d60d0e829e4707658f1667f288b3d59f4078022bee8f38fd4a2a5be4bd3e9697fc44bdf1125a803221e0a53fb7287f449cbd0946d88149a79aa8438ddd9e1c65e4a44385df6e3a1ce8747b474ec05c59ae7b24a0edc2aeb3bfdb935ee91b3f898fc3762c4dc7a9dc91de50be1114498d86887b4c7f32ef86d08402d93941a181688ac8edcd35c1509e9d0aa374a397ef17da508c6be723246a123a52ca54106058fabde6eae66b7a5d8c1d5f6601eb2f68969ed0bc2094c7ff7eacfb70be4ff0d87f4434880455850b8882bb2f604e2c4db3cf3c99ae1d3b75c62dff30d988f80cdf2b8ede8754454fdc6c63d38e574bcdf0065c557eda627e7f1",
    "c5df0e64ae84f74228f0195c6c57682ae17fe8f75c21caa380a826ae7dbb7098e1a38ee831e84531f3d321bd9f16e96e2f6e1a6af4e8bdb291004a7c9823e07030c7655bc49339bab6832b8b360484d292ad127b8b2570a5ddf1ed91d8d5a11b2c6acfc7b2ca66d554b100d4baa85b46de3b16983ec5aef7ee2512ee9941e23aefc28e5d2037efa6c7da1fe95601c577c827b31300477d9e0ef30cbf4d7f9faa8686c4d1e03740c3a29db6bc72b654225c13f59c2561f5a2d594687f46e5a3692286041842b04e2f046afb4ef52f4281b1c8ff3d5066b4b49e44c5976845d3fd6bb64f7554a862797bdf3851fe079a24a7adafdaede7f2b45ac9bd7c7ecf07c2583ea45f675f1d58ae3f93eb51cbde9f62974ddb2db2886ec1c5aec61803693319befea8c78b44b131ea4180cae6b4490197",
    "a19d5a4eac8be0427af703126a576827e532aced4a28dda5c5b629aa24bc71cce1af9fee31e40439bfcb26b7d842e5627c675529cbe1abe1c44253769632e07034947441d7d62ca8fb8e648e210484d5d3aa5160912522b092f1f08b8c81e3036263809483d67c9200ad01c2babb405ad37c11d76acceba7e82508e08a12f87aef84c8185430faa4cd891ee64201c27cc969e913004e289e12f404f662769fe3819d8dd1e03905f9aed8b5f37fb2012c5a479499297ebca0da9e687a5bffb46225830d5c0daa0736416aba55f77b0bcefd84923d5068f5c0804b8c8b"
    ]

main :: IO ()
main = do
    let ciphertexts = map hexToBytes encryptedMessages
    mapM_ (breakIO ciphertexts) ciphertexts

-- Process and decrypt a single ciphertext using information from all ciphertexts
breakIO :: [BS.ByteString] -> BS.ByteString -> IO ()
breakIO allCiphertexts targetCiphertext = do
    -- Make all ciphertexts the same length as the target ciphertext
    let normalizedCiphertexts = map (BS.take (BS.length targetCiphertext)) allCiphertexts

    -- Find space positions for all ciphertexts
    let ciphertextsWithSpaceInfo = analyzeAllCiphertexts normalizedCiphertexts

    -- Initialize empty key and update it with space information
    let emptyKey = replicate (fromIntegral $ BS.length targetCiphertext) Nothing
    let partialKey = createPartialKey emptyKey ciphertextsWithSpaceInfo

    -- Decrypt the target ciphertext
    putStrLn $ breakWithPartialKey (BS.unpack targetCiphertext) partialKey



-- XOR two ByteStrings together
bytesXor :: BS.ByteString -> BS.ByteString -> BS.ByteString
bytesXor a b = BS.pack $ zipWith xor (BS.unpack a) (BS.unpack b)

-- Convert a hexadecimal string to a ByteString
hexToBytes :: String -> BS.ByteString
hexToBytes [] = BS.empty
hexToBytes (a:b:rest) = BS.cons (fromIntegral $ hexValue a * 16 + hexValue b) (hexToBytes rest)
    where
        hexValue :: Char -> Int
        hexValue c
            | c >= '0' && c <= '9' = ord c - ord '0'
            | c >= 'a' && c <= 'f' = ord c - ord 'a' + 10
            | c >= 'A' && c <= 'F' = ord c - ord 'A' + 10
            | otherwise = error $ "Invalid hex character: " ++ [c]
hexToBytes _ = error "Invalid hex string: ciphertext must have even number of characters hex characters"



-- Check if a byte is likely to be a space in plaintext (1 for space locations, 0 otherwise)
markAsSpace :: Word8 -> Int
markAsSpace byte | isLikelySpace byte = 1
                 | otherwise = 0
    where isLikelySpace b = (b >= 65 && b <= 90) || (b >= 97 && b <= 122) || b == 0

-- Find likely space positions for two ciphertexts
detectSpacePositions :: BS.ByteString -> BS.ByteString -> [Int]
detectSpacePositions ciphertext1 ciphertext2 =
    map (markAsSpace . BS.index (bytesXor ciphertext1 ciphertext2)) [0 .. BS.length ciphertext1 - 1]

-- Find likely space positions for all ciphertexts
-- A position is likely a space if it produces a letter when XORed with most other ciphertexts
findLikelySpaces :: BS.ByteString -> [BS.ByteString] -> [Int]
findLikelySpaces target otherCiphertexts =
    let initialCounts = replicate (BS.length target) 0
        spaceIndicators = map (detectSpacePositions target) otherCiphertexts
        voteCounts = foldr (zipWith (+)) initialCounts spaceIndicators
        threshold = length otherCiphertexts - 2
    in map (\count -> if count > threshold then 1 else 0) voteCounts

-- Perform the findLikelySpaces function on each ciphertext to find likely space positions in each of them
analyzeAllCiphertexts :: [BS.ByteString] -> [(BS.ByteString, [Int])]
analyzeAllCiphertexts ciphertexts =
    map (\cipher -> (cipher, findLikelySpaces cipher (filter (/= cipher) ciphertexts))) ciphertexts



-- Create the partial key from the space information
-- Apply the updatePartialKey to the key for each ciphertext
createPartialKey :: [Maybe Word8] -> [(BS.ByteString, [Int])] -> [Maybe Word8]
createPartialKey emptyKey ciphertextsWithSpaces = xorWithSpace (foldl updatePartialKey emptyKey ciphertextsWithSpaces)
    where
        xorWithSpace = map (fmap (\b -> b `xor` fromIntegral (ord ' ')))

-- Update the partial key with the space information from a single ciphertext
updatePartialKey ::  [Maybe Word8] -> (BS.ByteString, [Int]) -> [Maybe Word8]
updatePartialKey oldKey (cipherText, spaceIndicators) = zipWith updateKeyByte oldKey (zip (BS.unpack cipherText) spaceIndicators)
    where 
        updateKeyByte currentByte (ciphertextByte, isSpace) = case (currentByte, isSpace) of
            (Nothing, 1) -> Just ciphertextByte
            (Just existing, 1) | existing == ciphertextByte -> Just existing
            _ -> currentByte



-- Decrypt a ciphertext using the partial key
breakWithPartialKey :: [Word8] -> [Maybe Word8] -> String
breakWithPartialKey = zipWith decryptByte
  where
    decryptByte b Nothing = '.'
    decryptByte b (Just keyByte) =
        if b == keyByte
        then ' '
        else chr $ fromIntegral (b `xor` keyByte)

\end{code}
